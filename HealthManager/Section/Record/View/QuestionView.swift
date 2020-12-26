//
//  QuestionView.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/22.
//

import UIKit

class QuestionView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewBottomSpace: NSLayoutConstraint!
    @IBOutlet var titleLb: UILabel!
    @IBOutlet var textView: UITextView!
    var titleStr = ""
    var contentStr = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setViewRadius(view: self.contentView, corners:UIRectCorner.init(rawValue:  UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 10)
    }
    
    func createSubviews() {
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)
        self.view.backgroundColor = .clear
        self.view.frame = self.bounds
        self.addSubview(self.view)
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
            self.contentViewBottomSpace.constant = -300;
            self.contentView.superview?.layoutIfNeeded()
        } completion: { (finish) in
            self.removeFromSuperview()
        }

    }

    @IBAction func sureAction(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func tapBackGes(_ sender: Any) {
        dismiss()
    }
    
}
