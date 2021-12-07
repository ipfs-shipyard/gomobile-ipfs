//
//  ViewController.swift
//  Example
//
//  Created by gfanton on 10/30/2019.
//  Copyright (c) 2019 gfanton. All rights reserved.
//
// Use some code from:
// https://medium.com/@deepakrajmurugesan/swift-access-ios-camera-photo-library-video-and-file-from-user-device-6a7fd66beca2

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices
import GomobileIPFS
import CoreImage.CIFilterBuiltins

class ViewController: UIViewController {
    @IBOutlet var PIDTitle: UILabel!
    @IBOutlet var PIDInfo: UILabel!
    @IBOutlet var PIDLoading: UIActivityIndicatorView!
    @IBOutlet weak var PeerCounter: UILabel!
    @IBOutlet weak var OnlineTitle: UILabel!
    @IBOutlet weak var XKCDButton: UIButton!
    @IBOutlet weak var OfflineTitle: UILabel!
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var FetchButton: UIButton!
    @IBOutlet weak var FetchProgress: UIActivityIndicatorView!
    @IBOutlet weak var FetchStatus: UILabel!
    @IBOutlet weak var FetchError: UILabel!

    static var ipfs: IPFS?

    var peerID : String?
    var peerCountUpdater: PeerCountUpdater?

    static let XKCDIPNS = "/ipns/xkcd.hacdias.com"
    var XKCDLatest: Int!
    
    var attachmentHandler: AttachmentHandler?
    var qrCodeScanner: ScannerViewController?

    static func getIpfs() -> IPFS? {
        return ipfs
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.PIDLoading.startAnimating()
        
        XKCDButton.addTarget(
            self,
            action: #selector(xkcdButtonClicked),
            for: .touchUpInside
        )
        
        ShareButton.addTarget(
            self,
            action: #selector(shareButtonClicked),
            for: .touchUpInside
        )

        FetchButton.addTarget(
            self,
            action: #selector(fetchButtonClicked),
            for: .touchUpInside
        )
        
        attachmentHandler = AttachmentHandler()
        attachmentHandler?.imagePickedBlock = { (image) in
            let data = image.jpegData(compressionQuality: 1)
            
            do {
                var bodyData = Data()
                bodyData.append("--------------------------5f505897199c8c52\n".data(using: .utf8)!)
                bodyData.append("Content-Disposition: form-data; name=\"file\"\n".data(using: .utf8)!)
                bodyData.append("Content-Type: application/octet-stream\n\n".data(using: .utf8)!)
                bodyData.append(data!)
                bodyData.append("\n--------------------------5f505897199c8c52--".data(using: .utf8)!)
                
                let body = RequestBody.bytes(bodyData)
                
                let res = try ViewController.ipfs!.newRequest("add")
                    .with(header: "Content-Type", value: "multipart/form-data; boundary=------------------------5f505897199c8c52")
                    .with(body: body)
                    .sendToDict()

                let cid = (res["Hash"] as! String)
                print("cid=\(cid)")
                
                let qrcode = self.generateQRCode(from: cid)
                self.displayFetchSuccess("Scan QR code", qrcode!)
            } catch let error {
                print("Error: can't fetch xkcd info: \(error)")
            }
        }
        
        qrCodeScanner = ScannerViewController()
        qrCodeScanner?.callback = { (code) in
            print(code)
            self.navigationController!.popViewController(animated: true)
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now(), execute: {
                 var error: String?
                 var title: String = ""
                 var image: UIImage = UIImage()
     
                 do {
                     let fetchedData = try ViewController.ipfs!.newRequest("cat")
                         .with(argument: code)
                         .send()
     
                     title = "IPFS File"
                     image = UIImage(data: fetchedData)!
                 } catch let err as IPFSError {
                     error = err.localizedFullDescription
                 } catch let err {
                     error = err.localizedDescription
                 }
                 DispatchQueue.main.async {
                     if let err = error {
                         self.displayFetchError(err)
                     } else {
                         self.displayFetchSuccess(title, image)
                     }
                 }
             })
        }

        DispatchQueue.global(qos: .background).async {
            var error: String?

            do {
                ViewController.ipfs = try IPFS()
                try ViewController.ipfs!.start()

                let res = try ViewController.ipfs!.newRequest("id").sendToDict()
                self.peerID = (res["ID"] as! String)
            } catch let err as IPFSError {
                error = err.localizedFullDescription
            } catch let err {
                error = err.localizedDescription
            }

            if let err = error {
                DispatchQueue.main.async { self.displayPeerIDError(err) }
            } else {
                DispatchQueue.main.async {
                    self.displayPeerID()
                    self.OnlineTitle.isHidden = false
                    self.OfflineTitle.isHidden = false
                    self.XKCDButton.isHidden = false
                    self.XKCDButton.isEnabled = true
                    self.FetchButton.isHidden = false
                    self.FetchButton.isEnabled = true
                    self.ShareButton.isHidden = false
                    self.ShareButton.isEnabled = true
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.peerCountUpdater?.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.peerCountUpdater?.stop()
    }

    private func displayPeerID() {
        self.PIDLoading.stopAnimating()
        self.PIDTitle.text = "Your PeerID is:"
        self.PIDInfo.text = self.peerID!

        print("Your PeerID is: \(self.peerID!)")
        initPeerCountUpdater()
    }

    private func displayPeerIDError(_ error: String) {
        self.PIDLoading.stopAnimating()

        PIDTitle.textColor = UIColor.red
        PIDInfo.textColor = UIColor.red

        self.PIDTitle.text = "Error:"
        self.PIDInfo.text = error

        print("IPFS start error: \(error)")
    }

    private func initPeerCountUpdater() {
        self.peerCountUpdater = PeerCountUpdater()
        self.peerCountUpdater!.start()

        PeerCounter.text = "Peers connected: 0"
        PeerCounter.isHidden = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePeerCount(_:)),
            name: Notification.Name("updatePeerCount"),
            object: nil
        )
    }

    @objc func updatePeerCount(_ notification: Notification) {
        var count: Int = 0

        if let data = notification.userInfo as? [String: Int] {
            count = data["peerCount"] ?? 0
        }

        PeerCounter.text = "Peers connected: \(count)"
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    @objc func xkcdButtonClicked() {
        self.displayFetchProgress()
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now(), execute: {
            var error: String?
            var title: String = ""
            var image: UIImage = UIImage()
            
            do {
                let list = try ViewController.ipfs!.newRequest("cat")
                    .with(argument: "\(ViewController.XKCDIPNS)/latest/info.json")
                    .sendToDict()
                self.XKCDLatest = (list["num"] as! Int)
                
                let randomIndex = Int(arc4random_uniform(UInt32(self.XKCDLatest))) + 1
                let formattedIndex = String(format: "%04d", randomIndex)
                
                let fetchedInfo = try ViewController.ipfs!.newRequest("cat")
                    .with(argument: "\(ViewController.XKCDIPNS)/\(formattedIndex)/info.json")
                    .sendToDict()
                
                let imgURL = fetchedInfo["img"] as! String
                let imgExt = imgURL.components(separatedBy: ".").last!.contains("png") ? "png" : "jpg"
                
                let fetchedData = try ViewController.ipfs!.newRequest("cat")
                    .with(argument: "\(ViewController.XKCDIPNS)/\(formattedIndex)/image.\(imgExt)")
                    .send()
                
                title = "\(randomIndex). \(fetchedInfo["title"] as! String)"
                image = UIImage(data: fetchedData)!
            } catch let err as IPFSError {
                error = err.localizedFullDescription
            } catch let err {
                error = err.localizedDescription
            }
            DispatchQueue.main.async {
                if let err = error {
                    self.displayFetchError(err)
                } else {
                    self.displayFetchSuccess(title, image)
                }
            }
        })
    }
    
    @objc func shareButtonClicked() {
        attachmentHandler?.showAttachmentActionSheet(vc:self)
    }
    
    private func displayFetchProgress() {
        FetchStatus.textColor = UIColor.black
        FetchStatus.text = "Fetching file on IPFS"
        FetchStatus.isHidden = false
        FetchProgress.startAnimating()
        FetchError.isHidden = true
        XKCDButton.isEnabled = false
        ShareButton.isEnabled = false
        FetchButton.isEnabled = false
    }

    private func displayFetchSuccess(_ title: String, _ image: UIImage) {
        FetchStatus.isHidden = true
        FetchProgress.stopAnimating()
        XKCDButton.isEnabled = true
        ShareButton.isEnabled = true
        FetchButton.isEnabled = true

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let displayImageController = storyBoard.instantiateViewController(withIdentifier: "DisplayImage") as! DisplayImageController
        displayImageController.xkcdTitle = title
        displayImageController.xkcdImage = image
        self.navigationController!.pushViewController(displayImageController, animated: true)
    }

    private func displayFetchError(_ error: String) {
        FetchStatus.textColor = UIColor.red
        FetchStatus.text = "Fetching file failed"
        FetchProgress.stopAnimating()
        FetchError.isHidden = false
        FetchError.text = error
        XKCDButton.isEnabled = true
        ShareButton.isEnabled = true
        FetchButton.isEnabled = true
    }

    @objc func fetchButtonClicked() {
        self.displayFetchProgress()

        self.navigationController!.pushViewController(qrCodeScanner!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
  
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}
