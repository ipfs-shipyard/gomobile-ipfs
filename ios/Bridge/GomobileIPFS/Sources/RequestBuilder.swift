//
//  RequestBuilder.swift
//  Bridge
//
//  Created by Guilhem Fanton on 14/01/2020.
//

import Foundation
import Core

public enum RequestOption {
    case bool(Bool)
    case string(String)
    case bytes(Data)
}

public enum RequestBody {
    case string(String)
    case bytes(Data)
}

public class RequestBuilderError: IPFSError {
    private static var code: Int = 6
    private static var subdomain: String = "RequestBuilder"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, RequestBuilderError.subdomain, RequestBuilderError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class RequestBuilder {
    private let reqb: CoreRequestBuilder

    internal init(reqb: CoreRequestBuilder) {
        self.reqb = reqb
    }

    public func with(arg: String) -> RequestBuilder {
        self.reqb.argument(arg)
        return self
    }

    public func with(option: String, val: RequestOption) -> RequestBuilder {
        switch val {
        case .bool(let bool):
            self.reqb.boolOptions(option, value: bool)
        case .string(let string):
            self.reqb.stringOptions(option, value: string)
        case .bytes(let data):
            self.reqb.byteOptions(option, value: data)
        }

        return self
    }

    public func with(body: RequestBody) -> RequestBuilder {
        switch body {
        case .bytes(let data):
            self.reqb.bodyBytes(data)
        case .string(let string):
            self.reqb.bodyString(string)
        }

        return self
    }

    public func with(header: String, val: String) -> RequestBuilder {
        self.reqb.header(header, value: val)
        return self
    }

    public func send() throws -> Data {
        do {
            return try self.reqb.send()
        } catch let error as NSError {
            throw RequestBuilderError("sending request failed", error)
        }
    }

    public func sendToDict() throws -> [String: Any] {
        let res = try self.reqb.send()

        do {
            let json = try JSONSerialization.jsonObject(with: res, options: [])
            return (json as? [String: Any])!
        } catch let error as NSError {
            throw RequestBuilderError("converting response to dict failed", error)
        }
    }
}
