//
//  RequestIPFSTests.swift
//  GomobileIPFSTests
//
//  Created by Antoine Eddi on 4/15/20.
//  Copyright © 2020 Antoine Eddi. All rights reserved.
//

import XCTest
import CryptoKit
@testable import GomobileIPFS

class RequestIPFSTests: XCTestCase {

    private var ipfs: IPFS!
    // This CID is the IPFS logo in the Wikipedia mirror. It should exist for a long time.
    private var fileUri: String = "/ipfs/bafkreifxaqwd63x4bhjj33sfm3pmny2codycx27jo77it33hkexzrawyma"
    private var expectedFileLength: Int = 2940
    private var expectedFileSha256: String =
        "SHA256 digest: b7042c3f6efc09d29dee4566dec6e34270f02bebe977fe89ef67512f9882d860"
    // The boundary for a multipart message is a unique string. See https://en.wikipedia.org/wiki/MIME#Multipart_messages
    private static var boundary : String = "------------------------f33e457ed9f80969"
    private var addRequestBody : Data =
        ("--" + boundary + "\r\n" +
        "Content-Disposition: form-data; name=\"file\"\r\n" +
        "Content-Type: application/octet-stream\r\n\r\n" +
        "hello" +
        "\r\n--" + boundary + "--\r\n").data(using: .utf8)!;
    private var addRequestExpectedHash: String = "QmWfVY9y3xjsixTgbd9AorQxH7VtMpzfx2HaWtsoUYecaX";

    override func setUp() {
        do {
            ipfs = try IPFS()
            try ipfs!.start()
        } catch _ {
            XCTFail("IPFS initialization failed")
        }
    }

    func testDNSRequest() throws {
        let domain = "website.ipfs.io"

        guard let resolveResp = try ipfs.newRequest("resolve")
            .with(argument: "/ipns/\(domain)")
            .sendToDict() else {
            XCTFail("error while casting dict for \"resolve\"")
            return
        }
        guard let dnsResp = try ipfs.newRequest("dns")
            .with(argument: domain)
            .sendToDict() else {
            XCTFail("error while casting dict for \"dns\"")
            return
        }

        guard let resolvePath = resolveResp["Path"] as? String else {
            XCTFail("error while casting value associated to \"Path\" key")
            return
        }
        guard let dnsPath = dnsResp["Path"] as? String else {
            XCTFail("error while casting value associated to \"Path\" key")
            return
        }
        let index = dnsPath.index(dnsPath.startIndex, offsetBy: 6)

        XCTAssertEqual(
            resolvePath,
            dnsPath,
            "resolve and dns request should return the same result"
        )

        XCTAssertEqual(
            dnsPath[..<index],
            "/ipfs/",
            "response should start with \"/ipfs/\""
        )
    }

    func testCatFile() throws {
        let response = try ipfs.newRequest("cat")
            .with(argument: fileUri)
            .sendToBytes()

        XCTAssertEqual(
            expectedFileLength,
            response!.count,
            "response should have the correct length"
        )
        XCTAssertEqual(
            expectedFileSha256,
            SHA256.hash(data: response!).description,
            "response should have the correct SHA256"
        )
    }

    func testCatFileStream() throws {
        var count = 0
        var hasher = SHA256()

        if let stream = try? ipfs.newRequest("cat")
                .with(argument: fileUri)
                .send() {
            var buf: [UInt8] = [UInt8](repeating: 0, count: 1000)
            stream.open()
            while case let len = stream.read(&buf, maxLength: buf.count), len > 0 {
                count += len
                hasher.update(data: buf[..<len])
            }
            stream.close()
        } else {
            XCTFail("error calling ipfs.newRequest")
        }

        XCTAssertEqual(
            expectedFileLength,
            count,
            "response should have the correct length"
        )
        XCTAssertEqual(
            expectedFileSha256,
            hasher.finalize().description,
            "response should have the correct SHA256"
        )
    }

    func testAddWithBytesBody() throws {
        guard let response = try ipfs.newRequest("add")
            .with(header: "Content-Type",
                    value: "multipart/form-data; boundary=" + RequestIPFSTests.boundary)
            .with(body: RequestBody.bytes(addRequestBody))
            .sendToDict() else {
            XCTFail("error while casting dict for \"add\"")
            return
        }
        guard let hash = response["Hash"] as? String else {
            XCTFail("error while casting value associated to \"Hash\" key")
            return
        }

        XCTAssertEqual(
            addRequestExpectedHash,
            hash,
            "Added file should have the correct CID"
        )
    }

    func testAddWithStreamBody() throws {
        guard let response = try ipfs.newRequest("add")
            .with(header: "Content-Type",
                    value: "multipart/form-data; boundary=" + RequestIPFSTests.boundary)
                .with(body: RequestBody.stream(InputStream(data: addRequestBody)))
            .sendToDict() else {
            XCTFail("error while casting dict for \"add\"")
            return
        }
        guard let hash = response["Hash"] as? String else {
            XCTFail("error while casting value associated to \"Hash\" key")
            return
        }

        XCTAssertEqual(
            addRequestExpectedHash,
            hash,
            "Added file should have the correct CID"
        )
    }
}
