//
//  ViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit
import Photos

typealias AuthStatusCheckCallBack = (Bool)->()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func checkCamaraStatus(_ completion:@escaping AuthStatusCheckCallBack) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                DispatchQueue.main.async {
                    if result == true {
                        completion(true)
                    }else {
                        completion(false)
                    }
                }
            }
        }else if authStatus == .authorized {
            completion(true)
        }else {
            completion(false)
        }
    }
    
    func openAppSettingPage()  {
        guard let appSetting = URL(string: UIApplication.openSettingsURLString)  else {
            return
        }
        if UIApplication.shared.canOpenURL(appSetting) {
            UIApplication.shared.open(appSetting, options: [UIApplication.OpenExternalURLOptionsKey : Any](), completionHandler: nil)
        }
    }
    
}
