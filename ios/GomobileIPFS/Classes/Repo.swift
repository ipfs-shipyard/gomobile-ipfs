//
//  Repo.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Mobile

public enum RepoError: Error {
  case error(String)
  case runtimeError(Error, String)
}

public class Repo {
    let goRepo: MobileRepo
    
    private let url: URL
    
    public init(_ url: URL) throws {
        self.url = url

        var err: NSError?
        if let repo = MobileOpenRepo(url.path, &err) {
            self.goRepo = repo
        } else {
            throw RepoError.error("failed to open repo, unknow error")
        }

        if let error = err {
             throw RepoError.runtimeError(error, "failed to open repo")
         }
    }
        
    public static func isInitialize(url: URL) throws -> Bool{
        return !(MobileRepoIsInitialized(url.path))
    }
    
    public static func initialize(url: URL, config: Config) throws {
        var err: NSError?
        MobileInitRepo(url.path, config.goConfig, &err)
        if let error = err {
             throw RepoError.runtimeError(error, "failed to open repo")
         }
    }
}
