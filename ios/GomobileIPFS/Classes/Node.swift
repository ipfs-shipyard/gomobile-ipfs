//
//  Node.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Ipfs

public enum NodeError: Error {
  case error(String)
  case runtimeError(Error, String)
}

public class Node {
    let node: IpfsNode

    public init(_ repo: Repo) throws {
        var err: NSError?

        if let node = IpfsNewNode(repo.goRepo, &err) {
            self.node = node
        } else if let error = err {
            throw NodeError.runtimeError(error, "failed to start node")
        } else {
            throw RepoError.error("failed start node, unknow error")
        }
    }

    public func close() throws {
        try self.node.close()
    }

    public func serve(onUDS: String) throws {
        try self.node.serveUnixSocketAPI(onUDS)
    }

    // return the multiaddr from listener
    public func serve(onTCPPort: String) throws -> String {
        var err: NSError?

        let maddr = self.node.serveTCPAPI(onTCPPort, error: &err)
        if let error = err {
            throw NodeError.runtimeError(error, "unable to serve api")
        }

        return maddr
    }
}
