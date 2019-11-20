//
//  IPFS.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 08/11/2019.
//

import Foundation
import Ipfs

extension FileManager {
    public var compatTemporaryDirectory: URL {
        if #available(iOS 10.0, *) {
            return temporaryDirectory
        } else {
            return (try? url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}


public enum IpfsError: CustomNSError {
    case nodeAlreadyStarted
    case nodeNotStarted

    case runtimeError(String)
    case runtime(Error, String)

    public static var errorDomain: String {
        return "IPFSDomain"
    }
}

public class IPFS: NSObject {
    public static let defaultRepoPath = "ipfs/repo"

    static let sockManager: SockManager = nil // FIXME: Use sockManager

    var node: Node? = nil
    var shell: IpfsShell? = nil
    var repo: Repo? = nil

    let absRepoURL: URL

    // init ipfs repo with the default or given path
    public init(_ repoPath: String = defaultRepoPath) throws {
        let absUserUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.absRepoURL = absUserUrl.appendingPathComponent(repoPath, isDirectory: true)

        // setup sockmanager if needed
        if self.sockManager == nil {
            let absTmpURL = FileManager.default.compatTemporaryDirectory
            self.sockManager = try SockManager(self.absTmpURL)
        }

        // init repo if needed
        if !(try Repo.isInitialized(url: absRepoURL)) {
            let config = try Config.defaultConfig()
            try Repo.initialize(url: absRepoURL, config: config)
        }

        super.init()
    }

    public func getRepoPath() -> URL {
		return self.absRepoURL
	}

    public func isStarted() -> Bool {
        return self.node != nil
    }

    public func start() throws {
        if self.isStarted() {
            throw IpfsError.nodeAlreadyStarted
        }

        var err: NSError?

        // open repo
        let repo = try Repo(self.absRepoURL)

        // init node
        let node = try Node(repo)

        // serve api
        let sockpath = try self.sockManager.newSockPath()
        print("sockpath", sockpath)
        try node.serve(sockpath: sockpath)

        // init shell
        if let shell = IpfsNewUDSShell(sockpath, &err) {
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

    public func stop() throws {
        if !self.isStarted() {
            throw IpfsError.nodeNotStarted
        }

        try self.node?.close()
		self.node = nil
    }

	public func restart() throws {
		try self.stop()
		try self.start()
	}

    public func shellRequest(_ command: String, b64Body: String) throws -> [String: Any] {
        if !self.isStarted() {
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
}
