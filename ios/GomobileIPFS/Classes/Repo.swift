//
//  Repo.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Ipfs

public class RepoError: IPFSError  {
    private static var code: Int = 4
    private static var subdomain: String = "Repo"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, RepoError.subdomain, RepoError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class Repo {
    let goRepo: IpfsRepo

    private let url: URL

    public init(_ url: URL) throws {
        var err: NSError?

        if let repo = IpfsOpenRepo(url.path, &err) {
            self.url = url
            self.goRepo = repo
        } else {
            throw RepoError("openning failed", err)
        }
    }

    public static func isInitialized(url: URL) throws -> Bool {
        return IpfsRepoIsInitialized(url.path)
    }

    public static func initialize(url: URL, config: Config) throws {
        var err: NSError?
        var isDirectory: ObjCBool = true
        let exist = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if !exist {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }

        IpfsInitRepo(url.path, config.goConfig, &err)
        if err != nil {
             throw RepoError("initialisation failed", err)
        }
    }

    public func getConfig() throws -> Config {
        let goconfig = try self.goRepo.getConfig()
        return Config(goconfig)
    }

    public func setConfig(_ config: Config) throws {
        do {
            try self.goRepo.setConfig(config.goConfig)
        } catch let error as NSError {
            throw RepoError("setting configuration failed", error)
        }
    }

}
