//
//  Config.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Ipfs

public class ConfigError: IPFSError  {
    private static var code: Int = 2
    private static var subdomain: String = "Config"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, ConfigError.subdomain, ConfigError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class Config {
    let goConfig: IpfsConfig

    public init(_ config: IpfsConfig) {
        self.goConfig = config
    }

    public class func defaultConfig() throws -> Config {
        var err: NSError?

        if let config = IpfsNewDefaultConfig(&err) {
            return Config(config)
        } else {
            throw ConfigError("default config creation failed", err)
        }
    }

    public class func emptyConfig() throws -> Config {
        var err: NSError?

        if let config = IpfsNewConfig("{}".data(using: .utf8), &err) {
            return Config(config)
        } else {
            throw ConfigError("empty config creation failed", err)
        }
    }

    public class func configFromDict(dict: [String: Any]) throws -> Config {
        var err: NSError?

        let json = try JSONSerialization.data(withJSONObject: dict)

        if let config = IpfsNewConfig(json, &err) {
            return Config(config)
        } else {
            throw ConfigError("config from dict creation failed", err)
        }
    }

    public func setKey(key: String, dict: [String: Any]) throws {
        do {
            let json = try JSONSerialization.data(withJSONObject: dict)
            try self.goConfig.setKey(key, raw_value: json)
        } catch let error as NSError {
            throw ConfigError("key setting failed", error)
        }
    }

    public func getKey(key: String) throws -> [String: Any] {
        do {
            let rawJson = try self.goConfig.getKey(key)
            let json = try JSONSerialization.jsonObject(with: rawJson, options: [])
            return json as! [String: Any]
        } catch let error as NSError {
            throw ConfigError("config key deserialization error", error)
        }
    }

    // Helper

    // set tcp api
    public func setTCPAPIWithPort(_ port: String) {
        self.goConfig.setupTCPAPI(port)
    }

    // set tcp api
    public func setupTCPGateway(_ port: String) {
        self.goConfig.setupTCPGateway(port)
    }

    // set unix socket api (sockfile is relative to repo folder)
    public func setupUnixSocketAPI(_ sockfile: String) {
        self.goConfig.setupUnixSocketAPI(sockfile)
    }

    // set unix socket gateway (sockfile is relative to repo folder)
    public func setupUnixSocketGateway(_ sockfile: String) {
        self.goConfig.setupUnixSocketGateway(sockfile)
    }

}
