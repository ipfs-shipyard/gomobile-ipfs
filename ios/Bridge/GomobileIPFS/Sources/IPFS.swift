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

/// IPFS is a class that wraps a go-ipfs node and its shell over UDS
public class IPFS {
    public static let defaultRepoPath = "ipfs/repo"

    private static var sockManager: SockManager?

    private var node: Node?
    private var shell: CoreShell?
    private var repo: Repo?

    private let absRepoURL: URL
    private let absSockPath: String

    /// Class constructor using repoPath passed as parameter on internal storage
    /// - Parameter repoPath: The path of the go-ipfs repo (default: `ipfs/repo`)
    /// - Throws:
    ///     - `SockManagerError`: If the initialization of SockManager failed
    ///     - `ConfigError`: If the creation of the config failed
    ///     - `RepoError`: If the initialization of the repo failed
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

    /// Returns the repo path as an URL
    /// - Returns: The repo path
    public func getRepoPath() -> URL {
		    return self.absRepoURL
	  }

    /// Returns True if this IPFS instance is "started" by checking if the underlying go-ipfs node is instantiated
    /// - Returns: True, if this IPFS instance is started
    public func isStarted() -> Bool {
        return self.node != nil
    }

    /// Starts this IPFS instance
    /// - Throws:
    ///     - `RepoError`: If the opening of the repo failed
    ///     - `NodeError`: If the node is already started or if its startup fails
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

    /// Stops this IPFS instance
    /// - Throws: `IPFSError`: If the node is already stopped or if its stop fails
    public func stop() throws {
        if !self.isStarted() {
            throw IPFSError("node already stopped")
        }

        try self.node?.close()
        self.node = nil
    }

    /// Restarts this IPFS instance
    /// - Throws:
    ///     - `IPFSError`: If the node is already stopped or if its stop fails
    ///     - `RepoError`: If the opening of the repo failed
    public func restart() throws {
        try self.stop()
        try self.start()
    }

    /// Creates and returns a RequestBuilder associated to this IPFS instance shell
    /// - Parameter command: The command of the request
    /// - Throws: `IPFSError`: If the request creaton failed
    /// - Returns: A RequestBuilder based on the command passed as parameter
    public func newRequest(_ command: String) throws -> RequestBuilder {
        guard let request = self.shell?.newRequest(command) else {
            throw IPFSError("unable to get shell, is the node started?")
        }

        return RequestBuilder(reqb: request)
    }

    /// Sets the primary and secondary DNS for gomobile (hacky, will be removed in future version)
    /// - Parameters:
    ///   - dnsaddr1: The primary DNS address in the form `<ip4>:<port>`
    ///   - dnsaddr2: The secondary DNS address in the form `<ip4>:<port>`
    public func setDNSPair(_ dnsaddr1: String, _ dnsaddr2: String) {
        CoreSetDNSPair(dnsaddr1, dnsaddr2, false)
    }
}
