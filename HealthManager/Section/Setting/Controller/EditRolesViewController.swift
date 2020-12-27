//
//  EditRolesViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/22.
//

import UIKit

class EditRolesViewController: ViewController, UITextFieldDelegate {

    
    @IBOutlet var manCheckBtn: UIButton!
    @IBOutlet var womanCheckBtn: UIButton!
    @IBOutlet var ageTf: UITextField!
    @IBOutlet var heightTf: UITextField!
    @IBOutlet var weightTf: UITextField!
    
    @UserDefaultBoolValue(key: "isSetPeople", defaultValue: false)
    var isSetPeople
    @UserDefaultIntValue(key: "sexStatus", defaultValue: 0)
    var sexStatus
    @UserDefaultStringValue(key: "ageStatus", defaultValue: "")
    var ageStatus
    @UserDefaultStringValue(key: "heightStatus", defaultValue: "")
    var heightStatus
    @UserDefaultStringValue(key: "weightStatus", defaultValue: "")
    var weightStatus
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .hex(0xF8F9FB)
        self.manCheckBtn.isSelected = self.sexStatus == 0 ? true : false
        self.womanCheckBtn.isSelected = self.sexStatus == 1 ? true : false
        self.ageTf.text = self.ageStatus == "" ? "" : self.ageStatus
        self.heightTf.text = self.heightStatus == "" ? "" : self.heightStatus
        self.weightTf.text = self.weightStatus == "" ? "" : self.weightStatus
        self.ageTf.keyboardType = .numberPad
        self.heightTf.keyboardType = .numberPad
        self.weightTf.keyboardType = .numberPad
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sexCheckAction(_ sender: UIButton) {
        if sender.tag == 1 {
            self.manCheckBtn.isSelected = true
            self.womanCheckBtn.isSelected = false
        }else {
            self.manCheckBtn.isSelected = false
            self.womanCheckBtn.isSelected = true
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let ageText = self.ageTf.text,
              ageText.count > 0 else {
            SVProgressHUD.showInfo(withStatus: "请填写年龄")
            return
        }
        guard let heightText = self.heightTf.text,
              heightText.count > 0 else {
            SVProgressHUD.showInfo(withStatus: "请填写身高")
            return
        }
        guard let weightText = self.weightTf.text,
              weightText.count > 0 else {
            SVProgressHUD.showInfo(withStatus: "请填写体重")
            return
        }
        self.sexStatus = self.manCheckBtn.isSelected == true ? 0 : 1
        self.ageStatus = ageText
        self.heightStatus = heightText
        self.weightStatus = weightText
        self.isSetPeople = true
        self.navigationController?.popViewController(animated: true)
    }
    

}
