//
//  SettingViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit

class SettingViewController: ViewController {

    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var sexLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var numLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    
    @UserDefaultBoolValue(key: "isSetPeople", defaultValue: false)
    var isSetPeople
    @UserDefaultIntValue(key: "sexStatus", defaultValue: 0)
    var sexStatus
    @UserDefaultStringValue(key: "ageStatus", defaultValue: "--")
    var ageStatus
    @UserDefaultStringValue(key: "heightStatus", defaultValue: "--")
    var heightStatus
    @UserDefaultStringValue(key: "weightStatus", defaultValue: "--")
    var weightStatus
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .hex(0xF8F9FB)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSetPeople {
            self.headImageView.image = self.sexStatus == 0 ? UIImage(named: "男性") : UIImage(named: "女性")
            self.sexLabel.text = String(format: "%@岁/%@", self.ageStatus, self.sexStatus == 0 ? "男" : "女")
            self.heightLabel.text = String(format: "身高:%@cm 体重:%@kg", self.heightStatus, self.weightStatus)
            /*
                “克莱托指数”
                体重(kg)÷身高²(m)
                20-25正常，20以下瘦，25以上胖 你的体形是正常的哦～
            */
            guard let weight = Float(self.weightStatus), let height = Float(self.heightStatus)  else {
                fatalError("身高体重问题")
            }
            let klt:Float = weight/(height/100 * height/100)
            self.numLabel.text = String(format: "%.1f", klt)
            if klt > 25.0 {
                self.resultLabel.text = "你的体形是偏胖的哦～"
            }else if klt < 20 {
                self.resultLabel.text = "你的体形是偏瘦的哦～"
            }else {
                self.resultLabel.text = "你的体形是正常的哦～"
            }
        }
    }

    // MARK: - Action
    @IBAction func editAction(_ sender: Any) {
        let vc = EditRolesViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func questionAction(_ sender: Any) {
        let view = QuestionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.titleLb.text = "克莱托指数"
        view.textView.text = "“克莱托指数”\n体重(kg)÷身高²(m)\n20-25正常，20以下瘦，25以上胖"
        view.show()
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        
    }
    
    @IBAction func likeAction(_ sender: Any) {
        let path = "itms-apps://itunes.apple.com/app/id\(AppInStoreID)?action=write-review"
        guard let url = URL(string: path) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey : Any](), completionHandler: nil)
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let activity = UIActivityViewController(activityItems: [APP.appDownloadUrl], applicationActivities: nil)
        AppDelegate.shareDelegate?.navigationController.present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        let vc = AboutUsViewController()
        self.navigationController?.pushViewController(vc)
    }
    
}
