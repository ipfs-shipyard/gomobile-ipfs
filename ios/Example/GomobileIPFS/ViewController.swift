//
//  ViewController.swift
//  GomobileIPFS
//
//  Created by gfanton on 10/30/2019.
//  Copyright (c) 2019 gfanton. All rights reserved.
//

import UIKit
import GomobileIPFS

class ViewController: UIViewController {
    @IBOutlet var PIDTitle: UILabel!
    @IBOutlet var PIDInfo: UILabel!
    @IBOutlet var PIDLoading: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.PIDLoading.startAnimating()

        do {
            let ipfs = try IPFS()
            try ipfs.start()

            let res = try ipfs.commandToDict("id")
            let peerID = res["ID"] as! String
            print("Your PeerID is: \(peerID)")

            self.PIDLoading.stopAnimating()
            self.PIDInfo.text = peerID
        } catch let error as IpfsError {
            if error.failureReason != nil {
                printError("\(error.errorDescription): \(error.failureReason!)")
            } else {
                printError(error.errorDescription)
            }
        } catch let error {
            printError(error.localizedDescription)
        }
    }

    private func printError(_ error: String) {
        print(error)

        self.PIDLoading.stopAnimating()

        PIDTitle.textColor = UIColor.red
        PIDInfo.textColor = UIColor.red

        self.PIDTitle.text = "Error:"
        self.PIDInfo.text = error
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
