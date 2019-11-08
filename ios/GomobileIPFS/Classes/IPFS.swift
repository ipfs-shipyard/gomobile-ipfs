//
//  IPFS.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 08/11/2019.
//

import Foundation
import Mobile

public enum IpfsError: CustomNSError {
    case nodeAlreadyStarted
    case nodeNotStarted

    case runtimeError(String)
    case runtime(Error, String)

    public static var errorDomain: String {
        return "IPFSDomain"
    }
}

let sockName = "api.sock"

public class IPFS: NSObject {
    var node: Node? = nil
    var shell: MobileShell? = nil
    var repo: Repo? = nil

    let repoPath: URL

    // init ipfs repo with the given path
    public init(_ repoPath: URL) throws {
        // init repo if needed
        if !(try Repo.isInitialized(url: repoPath)) {
            let config = try Config.defaultConfig()
            config.setupUnixSocketAPI(sockName)
            try Repo.initialize(url: repoPath, config: config)
        }

        self.repoPath = repoPath
        super.init()
    }

    public func start() throws {
        guard self.node == nil else {
            throw IpfsError.nodeAlreadyStarted
        }

        var err: NSError?

        // open repo
        let repo = try Repo(self.repoPath)

        // init node
        let node = try Node(repo)

        // init shell
        let sock = self.repoPath.appendingPathComponent(sockName)
        if let shell = MobileNewUDSShell(sock.path, &err) {
            self.shell = shell
        } else {
            throw IpfsError.runtimeError("unable to get shell")
        }

        if let err = err {
            throw IpfsError.runtime(err, "unable to start shell")
        }

        self.repo = repo
        self.node = node
    }

    public func shell(_ command: String, b64Body: String) throws -> [String: Any] {
        guard node != nil else {
            throw IpfsError.nodeNotStarted
        }

        var body: Data? = nil
        if b64Body.count > 0 {
            body = Data(base64Encoded: b64Body, options: .ignoreUnknownCharacters)
        }

        guard let rawJson = try self.shell?.request(command, body: body) else {
            throw IpfsError.runtimeError("failed to fetch shell, empty response")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: rawJson, options: []) else {
            throw IpfsError.runtimeError("failed to deserialize response, empty response")
        }
        
        guard let dict = json as? [String: Any] else {
            throw IpfsError.runtimeError("failed to convert json to dictionary")
        }

        return dict
    }

    public func stop() throws {
        guard node != nil else {
            throw IpfsError.nodeNotStarted
        }

        try self.node?.close()
    }
}
