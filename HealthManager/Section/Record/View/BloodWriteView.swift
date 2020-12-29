//
//  BloodWriteView.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit
import IQKeyboardManagerSwift

class BloodWriteView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewBottomSpace: NSLayoutConstraint!
    @IBOutlet var temperatureTF: UITextField!
    @IBOutlet var infoView: UIView!
    
    override func draw(_ rect: CGRect) {
        setViewRadius(view: self.contentView, corners:UIRectCorner.init(rawValue:  UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 10)
        setViewRadius(view: self.infoView, corners:UIRectCorner.init(rawValue:  UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 25)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubviews()
    }
    
    func createSubviews() {
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        Bundle.main.loadNibNamed("BloodWriteView", owner: self, options: nil)
        self.view.backgroundColor = .clear
        self.view.frame = self.bounds
        self.addSubview(self.view)
        self.temperatureTF.keyboardType = .numberPad
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    func show() {
        AppDelegate.shareDelegate?.window?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.contentViewBottomSpace.constant = 0;
            self.contentView.superview?.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .clear
            self.contentViewBottomSpace.constant = -537;
            self.contentView.superview?.layoutIfNeeded()
        } completion: { (finish) in
            self.removeFromSuperview()
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }

    }
    
    // MARK: - Action
    @IBAction func saveAction(_ sender: Any) {
        guard let str = self.temperatureTF.text, str.count > 0 else {
            SVProgressHUD.showInfo(withStatus: "请输入血压值")
            return
        }
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm"
        let currentDateStr = dateFormat.string(from: Date())
        let currentTimeStr = timeFormat.string(from: Date())
        let bloodPressure = BloodPressure(num: str, dateString: currentDateStr, timeString: currentTimeStr)
        BloodPressure.insert(bloodPressure: bloodPressure)
        SVProgressHUD.showSuccess(withStatus: "保存成功")
        //刷新本地数据的通知
        NotificationCenter.default.post(name: APP.homeDateChanged, object: nil)
        dismiss()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.temperatureTF.isEditing {
            dismiss()
        }else {
            self.temperatureTF.resignFirstResponder()
        }
    }

}
