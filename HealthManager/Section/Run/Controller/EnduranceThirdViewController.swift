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
    var rateSum:Int = 0 //心率总和
    
    @UserDefaultBoolValue(key: "detectionShowTip", defaultValue: false)
    var detectionShowTip
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //无权限弹窗
    func showNoAuthAlert() {
        let alert = UIAlertController.init(title: "权限提醒", message: "需要您开启摄像头权限才能进行心率检测", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { (cancel) in
            self.openAppSettingPage()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (retry) in
        
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //提示放手指的弹窗
    func showTipAlert() {
        let alert = UIAlertController.init(title: "手指放置好了吗？", message: "请确认", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "不再提示", style: .default, handler: { (cancel) in
            self.detectionShowTip = true
            self.heartRateDetection(AnyClass.self)
        }))
        alert.addAction(UIAlertAction(title: "好了", style: .default, handler: { (retry) in
            let vc = HeartRateViewController()
            vc.isPop = false
            vc.completion = { rate in
                self.resultView.isHidden = false
                self.heartRateLb.text = String(format: "%d", rate)
                self.rateSum += rate
                if rate < 60 {
                    self.colorLb.text = "心率过缓"
                    self.colorLb.textColor = .hex(0x6986DC)
                }else if rate > 100 {
                    self.colorLb.text = "心率过快"
                    self.colorLb.textColor = .hex(0xFF1709)
                }else {
                    self.colorLb.text = "心率正常"
                    self.colorLb.textColor = .hex(0x53A200)
                }
            }
            let nav = NavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //返回提示框
    func showBackAlert() {
        let alert = UIAlertController.init(title: "返回将丢失数据", message: "请确认", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (back) in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (cancel) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        showBackAlert()
    }
    
    @IBAction func heartRateDetection(_ sender: Any) {
        self.checkCamaraStatus { (grant) in
            if grant == false {
                self.showNoAuthAlert()
                return
            }else {
                if self.detectionShowTip {
                    let vc = HeartRateViewController()
                    vc.isPop = false
                    vc.completion = { rate in
                        self.resultView.isHidden = false
                        self.heartRateLb.text = String(format: "%d", rate)
                        self.rateSum += rate
                        if rate < 60 {
                            self.colorLb.text = "心率过缓"
                            self.colorLb.textColor = .hex(0x6986DC)
                        }else if rate > 100 {
                            self.colorLb.text = "心率过快"
                            self.colorLb.textColor = .hex(0xFF1709)
                        }else {
                            self.colorLb.text = "心率正常"
                            self.colorLb.textColor = .hex(0x53A200)
                        }
                    }
                    let nav = NavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }else {
                    self.showTipAlert()
                }
            }
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let vc = EnduranceResultViewController()
        vc.rateSum = self.rateSum
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
