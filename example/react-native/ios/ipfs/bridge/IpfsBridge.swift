//
//  IpfsBridge.swift
//  berty
//
//  Created by Guilhem Fanton on 15/09/2019.
//

import Foundation
import os
import Mobile

@objc(BridgeModule)
class BridgeModule: NSObject {
  let repoPath: string
  let repo: MobileRepoProtocol
  let node: MobileNodeProtocol

  override init() {
    var isDirectory: ObjCBool = true
    self.repoPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

    super.init()
  }

  @objc func start(resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {

    if !(MobileRepoIsInitialized(self.repoPath)) {
      var isDirectory: ObjCBool = true
      let exist = FileManager.default.fileExists(atPath: self.repoPath, isDirectory: &isDirectory)
      if !exist {
        do {
          try FileManager.default.createDirectory(at: self.repoPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
          reject("\(String(describing: error.code))", error.userInfo.description, error)
        }
      }

      try {
        var config: MobileConfig = MobileNewDefaultConfig()
        MobileInitRepo(config)
      }
    }

  }

  // @objc func invoke(_ method: NSString, message: NSString,
  //                   resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
  //   var err: NSError?
  //   self.serialCoreQueue.sync {
  //     do {
  //       let ret = self.daemon.invoke(method as String, msgIn: message as String, error: &err)
  //       if let error = err {
  //         throw error
  //       }
  //       resolve(ret)
  //     } catch let error as NSError {
  //       reject("\(String(describing: error.code))", error.userInfo.description, error)
  //     }
  //   }
  // }

  // @objc func setCurrentRoute(_ route: String!) {
  //   CoreSetAppRoute(route)
  // }

  // @objc static func requiresMainQueueSetup() -> Bool {
  //   return false
  // }

  // @objc func getNotificationStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
  //   let current = UNUserNotificationCenter.current()

  //   current.getNotificationSettings(completionHandler: { (settings) in
  //     resolve(settings.authorizationStatus.rawValue)
  //   })
  // }

  // @objc func openSettings(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
  //   DispatchQueue.main.async {
  //     UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
  //   }
  // }
}
