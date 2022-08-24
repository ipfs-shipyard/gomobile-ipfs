//
//  InputStreamFromGo.swift
//  GomobileIPFS
//
//  Created by Antoine Eddi on 19/01/2020.
//

import Foundation
import Core

public class InputStreamFromGoError: IPFSError {
    private static var code: Int = 6
    private static var subdomain: String = "InputStreamFromGo"

    required init(_ description: String, _ optCause: NSError? = nil) {
        super.init(description, optCause, InputStreamFromGoError.subdomain, InputStreamFromGoError.code)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class InputStreamFromGo: InputStream {
    private var _streamStatus: Stream.Status
    private var _streamError: Error?
    private weak var _delegate: StreamDelegate?
    private var readCloser: CoreReadCloser

    init(_ readCloser: CoreReadCloser) {
        self._streamStatus = .notOpen
        self._streamError = nil
        self.readCloser = readCloser
        super.init(data: Data())
    }

    override public var hasBytesAvailable: Bool {
        if self.streamStatus == .atEnd || self.streamStatus == .closed {
            return false
        }
        return true
    }

    override public var streamStatus: Stream.Status {
        return _streamStatus
    }

    override public var streamError: Error? {
        return _streamError
    }

    override public var delegate: StreamDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    override public func open() {
        if self._streamStatus == .notOpen {
            self._streamStatus = .open
        }
    }

    override public func close() {
        if self._streamStatus != .closed {
            self._streamStatus = .closed
            try? self.readCloser.close()
        }
    }

    override public func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        if self._streamStatus != .open {
            self._streamError = InputStreamFromGoError("stream not opened (\(self._streamStatus))")
            return -1
        }

        self._streamStatus = .reading

        // swiftlint:disable todo
        // TODO: Use the buffer argument directly without making a copy.
        // swiftlint:enable todo
        let tmp: NSData? = NSMutableData(length: len)
        var read: Int = 0

        do {
            try self.readCloser.read(tmp as Data?, n: &read)
        } catch let err {
            if err.localizedDescription == "EOF" {
                self._streamStatus = .atEnd
                return 0
            }

            self._streamStatus = .error
            self._streamError = err
            return -1
        }

        tmp!.getBytes(buffer, length: read)
        self._streamStatus = .open

        return read
    }

    override public func getBuffer(
            _ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
            length len: UnsafeMutablePointer<Int>) -> Bool {
        return false
    }
}
