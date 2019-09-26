//
//  IpfsBridge.swift
//  IPFSMobileDemo
//
//  Created by Guilhem Fanton on 17/09/2019.

import Foundation
import os
import Mobile

enum BridgeError: Error {
  case runtimeError(String)
}

@objc(BridgeModule)
class BridgeModule: NSObject {
  let repoPath: String
  let apisock: String
  let gatewaysock: String

  var shell: MobileShell? = nil
  var node: MobileNodeProtocol?

  override init() {
    let dirurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    self.repoPath = dirurl.appendingPathComponent("ipfs/repo/").path
    self.apisock = dirurl.appendingPathComponent("ipfs/api.sock").path
    self.gatewaysock = dirurl.appendingPathComponent("ipfs/gateway.sock").path
    super.init()
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }

  func getShell() throws -> MobileShell? {
    var err: NSError?

    if self.shell == nil {
      self.shell = MobileNewUnixSocketShell(self.apisock, &err)
      if let error = err {
        throw error
      }
    }

    return self.shell
  }

  @objc func fetchShell(_ command: String, b64Body: String, resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    do {
      if let shell = try self.getShell() {
        var body: Data? = nil
        if b64Body.count > 0 {
          body = Data(base64Encoded: b64Body, options: .ignoreUnknownCharacters)
        }

        let res = try shell.request(command, body: body)
        resolve(res.base64EncodedString())
        return
      }

      let error = BridgeError.runtimeError("no shell is available")
      reject("", "no shell is available", error)
    } catch let error as NSError {
      reject("\(String(describing: error.code))", error.userInfo.description, error)
    }
  }

  @objc func start(_ resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    var err: NSError?

    if self.node != nil {
      let error = BridgeError.runtimeError("node already initialized") as NSError
      reject("", "node already initialized", error)
      return
    }

    if !(MobileRepoIsInitialized(self.repoPath)) {
      var isDirectory: ObjCBool = true
      let exist = FileManager.default.fileExists(atPath: self.repoPath, isDirectory: &isDirectory)
      if !exist {
        do {
          try FileManager.default.createDirectory(atPath: self.repoPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
          reject("\(String(describing: error.code))", error.userInfo.description, error)
          return
        }
      }

      let config: MobileConfig? = MobileNewDefaultConfig(&err)
      if let error = err {
        reject("\(String(describing: error.code))", error.userInfo.description, error)
        return
      }

      // setup unix socket api
      config?.setupUnixSocketAPI(self.apisock)

      // setup tcp api for the webui.
      // this is not secure, and only use for the sake of this
      // example since its required by the webui
      // @FIXME: use a random port
      config?.setupTCPAPI("59875")

      MobileInitRepo(self.repoPath, config, &err)
    }

    let repo = MobileOpenRepo(self.repoPath, &err)
    if let error = err {
      reject("\(String(describing: error.code))", error.userInfo.description, error)
      return
    }

    self.node = MobileNewNode(repo, &err)
    if let error = err {
      reject("\(String(describing: error.code))", error.userInfo.description, error)
      return
    }

    resolve(true)
  }
}
