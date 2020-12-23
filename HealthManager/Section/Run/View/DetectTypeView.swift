//
//  DetectTypeView.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/23.
//

import UIKit

enum DetectType:Int {
    case bloodPressureRecord = 0
    case heartRateDetection = 1
    case temperatureRecord = 2
}

typealias DetectTypeCompletion = (DetectType)->()

class DetectTypeView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewBottomSpace: NSLayoutConstraint!
    var completion:DetectTypeCompletion? = nil
    
    
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
        Bundle.main.loadNibNamed("DetectTypeView", owner: self, options: nil)
        self.view.frame = self.bounds
        self.view.alpha = 0
        self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.addSubview(self.view)
        self.contentViewBottomSpace.constant = AppDelegate.shareDelegate!.window!.safeAreaInsets.bottom + 49 + 25
    }
    
    func show() {
        AppDelegate.shareDelegate?.window?.addSubview(self)
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { (finished) in
            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }

    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { (finished) in
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 0
                self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { (finished) in
                self.removeFromSuperview()
            }
        }
    }

    // MARK - Action
    @IBAction func bloodRecordAction(_ sender: Any) {
        self.completion?(DetectType.bloodPressureRecord)
        self.dismiss()
    }
    
    @IBAction func heartRateAction(_ sender: Any) {
        self.completion?(DetectType.heartRateDetection)
        self.dismiss()
    }
    
    @IBAction func temperatureRecordAction(_ sender: Any) {
        self.completion?(DetectType.temperatureRecord)
        self.dismiss()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func tapBackGes(_ sender: Any) {
        self.dismiss()
    }
    
    
}
