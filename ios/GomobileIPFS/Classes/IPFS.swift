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

public class IPFS: NSObject {
    var node: Node? = nil
    var shell: MobileShell? = nil
    var repo: Repo? = nil

    public static let defaultRepoPath = "ipfs/repo"
    private static let sockName = "sock" // FIXME: Use sockManager

    let absRepoPath: URL

    // init ipfs repo with the default or given path
    public init(_ repoPath: String = defaultRepoPath) throws {
        let absDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let absRepoPath = absDirUrl.appendingPathComponent(repoPath, isDirectory: true)

        // FIXME: Init sockManager with tmp folder

        // init repo if needed
        if !(try Repo.isInitialized(url: absRepoPath)) {
            let config = try Config.defaultConfig()
            config.setupUnixSocketAPI(IPFS.sockName)
            try Repo.initialize(url: absRepoPath, config: config)
        }

        self.absRepoPath = absRepoPath
        super.init()
    }

    public func getRepoPath() -> URL {
		return self.absRepoPath
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
        let repo = try Repo(self.absRepoPath)

        // init node
        let node = try Node(repo)

        // init shell
        let sock = self.absRepoPath.appendingPathComponent(IPFS.sockName)
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
