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
    var rateSum:Int = 0 //心率总和
    
    @UserDefaultStringValue(key: "ageStatus", defaultValue: "")
    var ageStatus
    @UserDefaultIntValue(key: "ruffier", defaultValue: 0)
    var ruffier//耐力值
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ruffier = (rateSum - 200)/10
        self.resultNumLb.text = String(format: "%d", ruffier)
        if self.ageStatus != "" && (Int(self.ageStatus) ?? 0 > 40) {
            if ruffier >= -5 && ruffier < 10 {
                self.resultColorLb.text = "心脏功能很好"
                self.resultColorLb.textColor = .hex(0x54A300)
            }else if ruffier >= 10 && ruffier < 20 {
                self.resultColorLb.text = "心脏功能一般"
                self.resultColorLb.textColor = .hex(0x69DDCB)
            }else {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xFF1709)
            }
        }else {
            if ruffier >= -5 && ruffier < 0 {
                self.resultColorLb.text = "心脏功能很好"
                self.resultColorLb.textColor = .hex(0x54A300)
            }else if ruffier >= 0 && ruffier < 5 {
                self.resultColorLb.text = "心脏功能还可以"
                self.resultColorLb.textColor = .hex(0x69DDCB)
            }else if ruffier >= 5 && ruffier < 10 {
                self.resultColorLb.text = "心脏功能一般"
                self.resultColorLb.textColor = .hex(0x7B69DD)
            }else if ruffier >= 10 && ruffier < 20 {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xDD8468)
            }else {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xFF1709)
            }
        }
        NotificationCenter.default.post(name: APP.ruffierChanged, object: nil)
    }


    //MARK - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @IBAction func questionAction(_ sender: Any) {
        let view = QuestionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.titleLb.text = "耐力测试"
        view.textView.text = "这是一项很简单的测试，可以让您了解自己的心脏耐力情况。这项测试被称为Ruffier测试。\n20至40岁:\n指数在-5到0之间:心脏功能很好;\n指数在0到5之间:心脏功能还可以;\n指数在5到10之间:心脏功能- -般;\n指数在10到20之间:心脏功能弱;\n20以上:心脏功能不正常;\n40岁以上\n指数在-5到10之间:心脏功能很好;\n指数在10到20之间:心脏功能- -般;\n20以上:心脏功能弱;"
        view.show()
    }
    
    @IBAction func completionAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    

}
