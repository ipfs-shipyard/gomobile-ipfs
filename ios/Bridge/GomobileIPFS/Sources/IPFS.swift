//
//  IPFS.swift
//  Bridge
//
//  Created by Guilhem Fanton on 08/11/2019.
//

import Foundation
import Core

extension FileManager {
    public var compatTemporaryDirectory: URL {
        if #available(iOS 10.0, *) {
            return temporaryDirectory
        } else {
            return (try? url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
              ) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

public class IPFS {
    public static let defaultRepoPath = "ipfs/repo"

    private static var sockManager: SockManager?

    private var node: Node?
    private var shell: CoreShell?
    private var repo: Repo?

    private let absRepoURL: URL
    private let absSockPath: String

    public init(_ repoPath: String = defaultRepoPath) throws {
        let absUserUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.absRepoURL = absUserUrl.appendingPathComponent(repoPath, isDirectory: true)

        // Instantiate sockManager singleton if needed
        #if !targetEnvironment(simulator)
        if IPFS.sockManager == nil {
            let absTmpURL = FileManager.default.compatTemporaryDirectory
            IPFS.sockManager = try SockManager(absTmpURL)
        }

        self.absSockPath = try IPFS.sockManager!.newSockPath()
        #else // On simulator we can't create an UDS, see comment below
        self.absSockPath = ""
        #endif

        // Init IPFS Repo if not already initialized
        if !Repo.isInitialized(url: absRepoURL) {
            let config = try Config.defaultConfig()
            try Repo.initialize(url: absRepoURL, config: config)
        }
    }

    public func getRepoPath() -> URL {
		    return self.absRepoURL
	  }

    public func isStarted() -> Bool {
        return self.node != nil
    }

    public func start() throws {
        if self.isStarted() {
            throw IPFSError("node already started")
        }

        // Open go-ipfs repo
        let repo = try Repo(self.absRepoURL)

        // Instanciate the node
        let node = try Node(repo)

        // Create a shell over UDS on physical device
        #if !targetEnvironment(simulator)
        try node.serve(onUDS: self.absSockPath)
        self.shell = CoreNewUDSShell(self.absSockPath)
        /*
         ** On iOS simulator, temporary directory's absolute path exceeds
         ** the length limit for Unix Domain Socket, since simulator is
         ** only used for debug, we can safely fallback on shell over TCP
         */
        #else
        let maddr: String = try node.serve(onTCPPort: "0")
        self.shell = CoreNewShell(maddr)
        #endif

        self.repo = repo
        self.node = node
    }

    public func stop() throws {
        if !self.isStarted() {
            throw IPFSError("node already stopped")
        }

        try self.node?.close()
        self.node = nil
    }

    public func restart() throws {
        try self.stop()
        try self.start()
    }

    public func newRequest(_ command: String) throws -> RequestBuilder {
        guard let request = self.shell?.newRequest(command) else {
            throw IPFSError("unable to get shell, is the node started?")
        }

        return RequestBuilder(reqb: request)
    }

    public func setDNSPair(_ dnsaddr1: String, _ dnsaddr2: String) {
        CoreSetDNSPair(dnsaddr1, dnsaddr2, false)
    }
}
