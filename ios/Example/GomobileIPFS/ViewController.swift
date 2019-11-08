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
        
    var ipfs: IPFS? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dirurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let repoPath = dirurl.appendingPathComponent("repo", isDirectory: true)
        
        do {
            let ipfs = try IPFS(repoPath)
            try ipfs.start()

            let res = try ipfs.shell("id", b64Body: "")

            self.PeerID.text = res["ID"] as? String
        } catch let error {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
