//
//  AppDelegate.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shareDelegate:AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var window: UIWindow?
    
    lazy var navigationController: NavigationController = {
        let nav = NavigationController()
        return nav
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configSDK()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        navigationController.setViewControllers([RootTabBarController()], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }
    
    func configSDK() {
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        SVProgressHUD.setBackgroundColor(UIColor(hex: 0x444444, transparency: 0.88)!)
        //SVProgressHUD.setInfoImage(UIImage())
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 40))
        SVProgressHUD.setDefaultStyle(.dark)
        
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey(UMengAppKey, channel: "App Store")
        UMConfigure.setLogEnabled(false)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

}

