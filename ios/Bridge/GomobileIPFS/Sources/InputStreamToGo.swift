//
//  InputStreamToGo.swift
//  GomobileIPFS
//
//  Created by CI Agent on 20/01/2020.
//

import Foundation
import Ipfs

public class InputStreamToGo: NSObject, IpfsReaderProtocol {
    private var inputStream: InputStream

    init(_ inputStream: InputStream) {
        self.inputStream = inputStream
        self.inputStream.open()
    }

    public func read(_ p0: Data?, n: UnsafeMutablePointer<Int>?) throws {
        var read: Int

        var bytes = UnsafeMutablePointer<UInt8>((p0 as! NSData).bytes)
        read = self.inputStream.read(p0, maxLength: p0?.count)
        n?.initialize(to: read)

        if read == 0 && self.inputStream.streamStatus == .atEnd {
            self.inputStream.close()
            throw NSError(domain: "", code: 0, userInfo: ["NSLocalizedDescription": "EOF"])
        }
    }
}
