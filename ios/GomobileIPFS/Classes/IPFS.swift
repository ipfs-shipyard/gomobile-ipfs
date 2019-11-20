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

    static var sockManager: SockManager? = nil

    var node: Node? = nil
    var shell: IpfsShell? = nil
    var repo: Repo? = nil

    let absRepoURL: URL
    let absSockPath: String

    // init ipfs repo with the default or given path
    public init(_ repoPath: String = defaultRepoPath) throws {
        let absUserUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.absRepoURL = absUserUrl.appendingPathComponent(repoPath, isDirectory: true)

        // init sockmanager singleton if needed
        if IPFS.sockManager == nil {
            let absTmpURL = FileManager.default.compatTemporaryDirectory
            IPFS.sockManager = try SockManager(absTmpURL)
        }

        self.absSockPath = try IPFS.sockManager!.newSockPath()

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
        try node.serveOnUDS(sockpath: self.absSockPath)

        // init shell
        if let shell = IpfsNewUDSShell(self.absSockPath, &err) {
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

    public func command(_ command: String, body: Data? = nil) throws -> Data {
        if !self.isStarted() {
            throw IpfsError.nodeNotStarted
        }

        guard let raw = try self.shell?.request(command, body: body) else {
            throw IpfsError.runtimeError("failed to fetch shell, empty response")
        }

        return raw
    }

    public func commandToDict(_ command: String, body: Data? = nil) throws -> [String: Any] {
        let raw = try self.command(command, body: body)

        guard let json = try? JSONSerialization.jsonObject(with: raw, options: []) else {
            throw IpfsError.runtimeError("failed to deserialize response, empty response")
        }

        guard let dict = json as? [String: Any] else {
            throw IpfsError.runtimeError("failed to convert json to dictionary")
        }

        return dict
    }
}
