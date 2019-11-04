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
    @IBOutlet weak var PeerID: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bridge = BridgeModule()
        do {
            try bridge.start()
            let raw = try bridge.fetchShell("id", b64Body: "")

            if let dict = try JSONSerialization.jsonObject(with: raw, options: []) as? [String: Any] {
                self.PeerID.text = dict["ID"] as? String
            }
        } catch let error {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

