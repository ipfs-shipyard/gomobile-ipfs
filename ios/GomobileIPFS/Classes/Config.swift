//
//  Config.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 07/11/2019.
//

import Foundation
import Mobile

public enum ConfigError: Error {
  case error(String)
  case runtimeError(Error, String)
}

public class Config {
    let goConfig: MobileConfig
    
    public init(_ config: MobileConfig) {
        self.goConfig = config
    }
    
    public class func defaultConfig() throws -> Config {
        var err: NSError?
        let config: MobileConfig? = MobileNewDefaultConfig(&err)
        if let error = err {
            throw ConfigError.runtimeError(error, "failed to create default config")
        }
        
        return Config(config!)
    }

    public class func emptyConfig() throws -> Config {
        var err: NSError?
        let config: MobileConfig? = MobileNewConfig("{}".data(using: .utf8), &err)
        if let error = err {
            throw ConfigError.runtimeError(error, "failed to create empty config")
        }

        return Config(config!)
    }

    public class func configFromDict(dict: [String: Any]) throws -> Config {
        var err: NSError?
                
        let json = try JSONSerialization.data(withJSONObject: dict)
        let config: MobileConfig? = MobileNewConfig(json, &err)
        if let error = err {
            throw ConfigError.runtimeError(error, "failed to create config from dict")
        }

        return Config(config!)
    }

    public func setKey(key: String, dict: [String: Any]) throws {
        let json = try JSONSerialization.data(withJSONObject: dict)
        try self.goConfig.setKey(key, raw_value: json)
        
    }
    
    public func getKey(key: String) throws -> [String: Any] {
        let rawJson = try self.goConfig.getKey(key)
        if let json = try? JSONSerialization.jsonObject(with: rawJson, options: []) {
            if let dict = json as? [String: Any] {
                return dict
            }
        }
        
        throw ConfigError.error("json deserialization error")
    }
}
