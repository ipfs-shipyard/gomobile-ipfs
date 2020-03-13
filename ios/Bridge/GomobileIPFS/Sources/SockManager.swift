//
//  SockManager.swift
//  Bridge
//
//  Created by Guilhem Fanton on 18/11/2019.
//

import Foundation
import Core

public class SockManagerError: IPFSError {
    private static var code: Int = 5
    private static var subdomain: String = "SockManager"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, SockManagerError.subdomain, SockManagerError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class SockManager {
    let sockManager: CoreSockManager

    public init(_ sockBasePath: URL) throws {
        var err: NSError?

        if let sman = CoreNewSockManager(sockBasePath.path, &err) {
            self.sockManager = sman
        } else {
            throw SockManagerError("initialization failed", err)
        }
    }

    public func newSockPath() throws -> String {
        var err: NSError?

        let path = self.sockManager.newSockPath(&err)

        if err != nil {
            throw SockManagerError("socket path creation failed", err)
        }

        return path
    }
}
