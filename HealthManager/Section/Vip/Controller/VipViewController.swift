//
//  VipViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit

typealias PurchaseSuccessCompletion = ()->()
typealias PurchaseCancelCompletion = ()->()

class VipViewController: ViewController {

    @IBOutlet var restoreBtn: UIButton!
    @IBOutlet var payBtn: UIButton!
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var topImageHeight: NSLayoutConstraint!
    @IBOutlet var tipLb: UILabel!
    @IBOutlet var timeLb: UILabel!
    @IBOutlet var priceLb: UILabel!
    @IBOutlet var bottomView: UIView!
    var success:PurchaseSuccessCompletion? = nil
    var cancel:PurchaseCancelCompletion? = nil
    var isVip = false
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MobClick.event("vippagenum")
        
        if APP.isIphoneX {
            self.topImageHeight.constant = 240
            self.topImageView.image = UIImage(named: "付费-顶部X")
        }else {
            self.topImageHeight.constant = 154.5
            self.topImageView.image = UIImage(named: "付费-顶部")
        }
        
        updateView()
    }

    func updateView() {
        if IAPManager.shared.purchased {
            self.restoreBtn.isHidden = true
            //self.priceLb.isHidden = true
            self.tipLb.isHidden = true
            self.timeLb.isHidden = false
            self.payBtn.isHidden = true
            self.bottomView.isHidden = true
            self.timeLb.text = "已成为尊贵的高级会员\n请尽情享受会员功能"
        }else {
//            let str = "3天免费试用\n之后¥298/每年自动续订"
//            let attStr:NSMutableAttributedString = NSMutableAttributedString(string: str)
//            let range:NSRange = (str as NSString).range(of: "¥298")
//            attStr.addAttribute(NSAttributedString.Key.font, value: UIFont.pingFangSemibold(18), range: range)
//            attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.hex(0x000000), range: range)
//            self.tipLb.attributedText = attStr
            self.restoreBtn.isHidden = false
            //self.priceLb.isHidden = false
            self.tipLb.isHidden = false
            self.timeLb.isHidden = true
            self.payBtn.isHidden = false
            self.bottomView.isHidden = false
        }
    }

    
    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        if !IAPManager.shared.purchased {
            self.cancel?()
        }else {
            self.success?()
        }
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        SVProgressHUD.show()
        unableUserInteraction()
        IAPManager.shared.restorePurchase { [weak self] (success, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self?.enableUserInteraction()
                if success {
                    self?.updateView()
                    self?.success?()
                }else {
                    SVProgressHUD.showError(withStatus: error)
                }
            }
        }
    }
    
    @IBAction func payAction(_ sender: Any) {
        SVProgressHUD.show()
        unableUserInteraction()
        IAPManager.shared.purchase(InAppPurchasesYearKey) { [weak self] (success, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self?.enableUserInteraction()
                if success {
                    self?.updateView()
                }else {
                    SVProgressHUD.showError(withStatus: error)
                }
            }
        }
    }
    
    @IBAction func userAction(_ sender: Any) {
        let url = Bundle.main.url(forResource: "hmuse", withExtension: "html")
        let vc = WebViewController(title: "用户协议", url: url)
        self.navigationController?.pushViewController(vc)
    }
    
    @IBAction func privacyAction(_ sender: Any) {
        let url = Bundle.main.url(forResource: "hmprivate", withExtension: "html")
        let vc = WebViewController(title: "隐私协议", url: url)
        self.navigationController?.pushViewController(vc)
    }
    
    func enableUserInteraction() {
        self.restoreBtn.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        self.payBtn.isUserInteractionEnabled = true
    }
    
    func unableUserInteraction() {
        self.restoreBtn.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        self.payBtn.isUserInteractionEnabled = false
    }

}
