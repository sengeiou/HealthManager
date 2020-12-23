//
//  AboutUsViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/22.
//

import UIKit

class AboutUsViewController: ViewController {

    @IBOutlet var versionLb: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.versionLb.text = "VERSION:\(APP.appVersion)"
        
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
