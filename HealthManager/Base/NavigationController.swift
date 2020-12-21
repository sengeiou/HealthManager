//
//  NavigationController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationBar.isTranslucent = false
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.delegate = nil
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            guard let vc = self.topViewController else { return false }
            return vc.prefersStatusBarHidden
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            guard let vc = self.topViewController else { return .lightContent }
            return vc.preferredStatusBarStyle
        }
    }

}
