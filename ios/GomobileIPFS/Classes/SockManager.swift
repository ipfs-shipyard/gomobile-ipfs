//
//  SockManager.swift
//  Pods
//
//  Created by Guilhem Fanton on 18/11/2019.
//

import Foundation
import Ipfs

public enum SockManagerError: Error {
  case error(String)
  case runtimeError(Error, String)
}

public class SockManager {
    let sockManager: IpfsSockManager
    
    public init(_ dir: URL) throws {
        var err: NSError?

        if let sm = IpfsNewSockManager(dir.path, &err) {
            self.sockManager = sm
        } else if let error = err {
            throw SockManagerError.runtimeError(error, "failed to start node")
        } else {
            throw SockManagerError.error("failed start node, unknow error")
        }
    }
    
    public func newSockPath() throws -> String {
        var err: NSError?

        let path = self.sockManager.newSockPath(&err)
        if let error = err { 
            throw SockManagerError.runtimeError(error, "cannot get new sock path")
        }
        
        return path
    }
}
