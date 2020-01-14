//
//  RequestBuilder.swift
//  GomobileIPFS
//
//  Created by Guilhem Fanton on 14/01/2020.
//

import Foundation
import Ipfs

public enum RequestOption {
    case Bool(Bool)
    case String(String)
    case Bytes(Data)
}

public enum RequestBody {
    case String(String)
    case Bytes(Data)
}

public class RequestBuilder {
    private let reqb: IpfsRequestBuilder

    internal init(reqb: IpfsRequestBuilder) {
        self.reqb = reqb
    }

    public func with(arg: String) -> RequestBuilder {
        self.reqb.argument(arg)
        return self
    }

    public func with(option: String, val: RequestOption) -> RequestBuilder {
        switch (val) {
        case .Bool(let bool):
            self.reqb.boolOptions(option, value: bool)
        case .String(let string):
            self.reqb.stringOptions(option, value: string)
        case .Bytes(let data):
            self.reqb.byteOptions(option, value: data)
        }

        return self
    }

    public func with(body: RequestBody) -> RequestBuilder {
        switch (body) {
        case .Bytes(let data):
            self.reqb.bodyBytes(data)
        case .String(let string):
            self.reqb.bodyString(string)
        }

        return self
    }

    public func withHeader(key: String, val: String) -> RequestBuilder {
        self.reqb.header(key, value: val)
        return self
    }

    public func send() throws -> Data {
        return try self.reqb.send()
    }

    public func sendToDict() throws -> [String: Any] {
        let res = try self.reqb.send()
        let json = try JSONSerialization.jsonObject(with: res, options: [])
        return json as! [String: Any]
    }

    public func exec() throws {
        try self.reqb.exec()
    }
}
