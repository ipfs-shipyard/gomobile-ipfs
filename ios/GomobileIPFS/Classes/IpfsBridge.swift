//
//  IpfsBridge.swift
//  IPFSMobileDemo
//
//  Created by Guilhem Fanton on 17/09/2019.

import Foundation
import os
import Mobile

public enum BridgeError: Error {
  case runtimeError(String)
  case runtime(Error, String)
}

public class BridgeModule {
  let repoPath: String
  let apisock: String
  let gatewaysock: String

  var shell: MobileShell? = nil
  var node: MobileNodeProtocol?

  public init() {
    let dirurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    self.repoPath = dirurl.appendingPathComponent("ipfs").path
    self.apisock = "api.sock"
    self.gatewaysock = "gateway.sock"
  }

  public func getShell() throws -> MobileShell? {
    var err: NSError?

    if self.shell == nil {
      self.shell = MobileNewUDSShell(self.repoPath + "/" + self.apisock, &err)
      if let error = err {
        throw error
      }
    }

    return self.shell!
  }

  public func fetchShell(_ command: String, b64Body: String) throws -> Data {
    if let shell = try self.getShell() {
      var body: Data? = nil
      if b64Body.count > 0 {
        body = Data(base64Encoded: b64Body, options: .ignoreUnknownCharacters)
      }

      return try shell.request(command, body: body)
    }

    throw BridgeError.runtimeError("no shell is available")
  }

  public func start() throws {
    var err: NSError?

    if self.node != nil {
      throw BridgeError.runtimeError("node already initialized")
    }

    if !(MobileRepoIsInitialized(self.repoPath)) {
      var isDirectory: ObjCBool = true
      let exist = FileManager.default.fileExists(atPath: self.repoPath, isDirectory: &isDirectory)
      if !exist {
        try FileManager.default.createDirectory(atPath: self.repoPath, withIntermediateDirectories: true, attributes: nil)
      }

      let config: MobileConfig? = MobileNewDefaultConfig(&err)
      if let error = err {
        throw BridgeError.runtime(error, "failed to create config")
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
      throw BridgeError.runtime(error, "failed to open repo")
    }

    self.node = MobileNewNode(repo, &err)
    if let error = err {
      throw BridgeError.runtime(error, "failed to create node")
    }
  }
}
