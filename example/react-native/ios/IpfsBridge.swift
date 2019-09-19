//
//  IpfsBridge.swift
//  IPFSMobileDemo
//
//  Created by Guilhem Fanton on 17/09/2019.

import Foundation
import os
import Mobile

@objc(BridgeModule)
class BridgeModule: NSObject {
  let repoPath: String
  var repo: MobileRepo?
  var node: MobileNodeProtocol?

  override init() {
    let dirurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    self.repoPath = dirurl.appendingPathComponent("ipfs/repo/").path
    super.init()
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }

  @objc func getApiAddrs(_ resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    if self.node != nil {
      if let addrs = self.node?.getApiAddrs() {
        resolve(addrs)
        return
      }
    }

    resolve("")
  }

  @objc func start(_ resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    var err: NSError?

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

      MobileInitRepo(self.repoPath, config, &err)
    }

    self.repo = MobileOpenRepo(self.repoPath, &err)
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
