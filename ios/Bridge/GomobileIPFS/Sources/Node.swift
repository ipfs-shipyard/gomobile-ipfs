//
//  Node.swift
//  Bridge
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Core

public class NodeError: IPFSError {
    private static var code: Int = 3
    private static var subdomain: String = "NodeManager"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, NodeError.subdomain, NodeError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class Node {
    let node: CoreNode

    public init(_ repo: Repo) throws {
        var err: NSError?

        if let node = CoreNewNode(repo.goRepo, &err) {
            self.node = node
        } else {
            throw NodeError("creation failed", err)
        }
    }

    public func close() throws {
        do {
            try self.node.close()
        } catch let error as NSError {
            throw NodeError("closing failed", error)
        }
    }

    public func serve(onUDS: String) throws {
        do {
            try self.node.serveUnixSocketAPI(onUDS)
        } catch let error as NSError {
            throw NodeError("unable to serve api on UDS", error)
        }
    }

    public func serve(onTCPPort: String) throws -> String {
        var err: NSError?

        let maddr = self.node.serveTCPAPI(onTCPPort, error: &err)

        if err != nil {
            throw NodeError("unable to serve api on TCP", err)
        }

        return maddr
    }
}
