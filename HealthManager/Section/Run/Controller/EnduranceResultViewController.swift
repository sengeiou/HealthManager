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
