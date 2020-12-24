//
//  EnduranceThirdViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit

class EnduranceThirdViewController: ViewController {

    @IBOutlet var resultView: UIView!
    @IBOutlet var heartRateLb: UILabel!
    @IBOutlet var colorLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func heartRateDetection(_ sender: Any) {
        self.resultView.isHidden = false
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let vc = EnduranceResultViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    

}
