//
//  InputStreamToGo.swift
//  GomobileIPFS
//
//  Created by CI Agent on 20/01/2020.
//

import Foundation
import Core

public class InputStreamToGo: NSObject, CoreNativeReaderProtocol {
    private var inputStream: InputStream

    init(_ inputStream: InputStream) {
        self.inputStream = inputStream
        self.inputStream.open()
    }

    public func nativeRead(_ size: Int) throws -> Data {
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        while true {
            let read = self.inputStream.read(bytes, maxLength: size)

            if read < 0 {
                throw self.inputStream.streamError!
            }
            if read == 0 && self.inputStream.streamStatus == .atEnd {
                self.inputStream.close()
                // The Swift/Go interface converts this to nil.
                return Data(count: 0)
            }
            if read > 0 {
                return Data(bytes: bytes, count: read)
            }

            // Iterate to read more than zero bytes.
        }
    }
}
