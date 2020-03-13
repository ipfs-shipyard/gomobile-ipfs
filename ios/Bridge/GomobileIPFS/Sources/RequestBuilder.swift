//
//  RequestBuilder.swift
//  Bridge
//
//  Created by Guilhem Fanton on 14/01/2020.
//

import Foundation
import Core

/// Enum of the different option types: bool, string and bytes
public enum RequestOption {
    case bool(Bool)
    case string(String)
    case bytes(Data)
}

/// Enum of the different body types: string and bytes
public enum RequestBody {
    case string(String)
    case bytes(Data)
}

/// RequestBuilderError is a RequestBuilder specific error (subclass of IPFSError)
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

/// RequestBuilder is an IPFS command request builder
public class RequestBuilder {
    private let reqb: CoreRequestBuilder

    internal init(reqb: CoreRequestBuilder) {
        self.reqb = reqb
    }

    /// Adds an argument to the request
    /// - Parameter arg: The argument to add
    /// - Returns: This instance of RequestBuilder
    public func with(arg: String) -> RequestBuilder {
        self.reqb.argument(arg)
        return self
    }

    /// Adds an option to the request
    /// - Parameters:
    ///   - option: The name of the option to add
    ///   - val: The value of the option to add
    /// - Returns: This instance of RequestBuilder
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

    /// Adds a body to the request
    /// - Parameter body: The value of body to add
    /// - Returns: This instance of RequestBuilder
    public func with(body: RequestBody) -> RequestBuilder {
        switch body {
        case .bytes(let data):
            self.reqb.bodyBytes(data)
        case .string(let string):
            self.reqb.bodyString(string)
        }

        return self
    }

    /// Adds a header to the request
    /// - Parameters:
    ///   - header: The key of the header to add
    ///   - val: The value of the header to add
    /// - Returns: This instance of RequestBuilder
    public func with(header: String, val: String) -> RequestBuilder {
        self.reqb.header(header, value: val)
        return self
    }

    /// Sends the request to the underlying go-ipfs node
    /// - Throws: `RequestBuilderError`: If sending the request failed
    /// - Returns: A Data object containing the response
    public func send() throws -> Data {
        do {
            return try self.reqb.send()
        } catch let error as NSError {
            throw RequestBuilderError("sending request failed", error)
        }
    }

    /// Sends the request to the underlying go-ipfs node and returns a dict
    /// - Throws: `RequestBuilderError`: If sending the request or converting the response failed
    /// - Returns: A dict containing the response
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
