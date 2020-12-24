//
//  EnduranceResultViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit

class EnduranceResultViewController: ViewController {
    
    @IBOutlet var resultNumLb: UILabel!
    @IBOutlet var resultColorLb: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    //MARK - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @IBAction func questionAction(_ sender: Any) {
        
    }
    
    @IBAction func completionAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    

}
