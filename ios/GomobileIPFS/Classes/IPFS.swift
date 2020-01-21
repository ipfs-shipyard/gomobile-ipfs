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
        #if !targetEnvironment(simulator)
        if IPFS.sockManager == nil {
            let absTmpURL = FileManager.default.compatTemporaryDirectory
            IPFS.sockManager = try SockManager(absTmpURL)
        }

        self.absSockPath = try IPFS.sockManager!.newSockPath()
        #else // On simulator we can't create an UDS, see comment below
        self.absSockPath = ""
        #endif

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
            throw IPFSError("node already started")
        }

        // open repo
        let repo = try Repo(self.absRepoURL)

        // init node
        let node = try Node(repo)

        // Create a shell over UDS on normal devices
        #if !targetEnvironment(simulator)
        try node.serve(onUDS: self.absSockPath)
        self.shell = IpfsNewUDSShell(self.absSockPath)
        /*
         ** On iOS simulator, temporary directory's absolute path exceeds
         ** the length limit for Unix Domain Socket, since simulator is
         ** only used for debug, we can safely fallback on shell over TCP
         */
        #else
        let maddr: String = try node.serve(onTCPPort: "0")
        self.shell = IpfsNewShell(maddr)
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

    public func setDNSPair(_ dnsaddr1: String, _ dnsaddr2: String, loadFromSystem: Bool = false) {
        IpfsSetDNSPair(dnsaddr1, dnsaddr2, loadFromSystem)
    }
}
