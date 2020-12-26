//
//  RootTabBarController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit
import ESTabBarController_swift

class RootTabBarController: ESTabBarController {
    
    let recordVC = RecordViewController()
    let runVC = RecordViewController()
    let settingVC = SettingViewController()
    var vipPresent:Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false

        self.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 1 {
                return true
            }
            return false
        }
        
        self.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            let view = DetectTypeView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            view.show()
            view.completion = { type in
                switch type {
                case .bloodPressureRecord:
                    self.bloodPressureRecord()
                case .heartRateDetection:
                    self.heartRateDetection()
                case .temperatureRecord:
                    self.temperatureRecord()
                }
                
            }
//            DispatchQueue.main.async {
//
//            }
        }
        
        recordVC.tabBarItem = ESTabBarItem(TabBarItemContentView(), title: "记录", image: UIImage(named: "记录-2"), selectedImage: UIImage(named: "记录-1"), tag: 0)
        runVC.tabBarItem = ESTabBarItem(TabBarItemCustomView(), title: "", image: UIImage(named: "首页-检测"), selectedImage: UIImage(named: "首页-检测"), tag: 1)
        settingVC.tabBarItem = ESTabBarItem(TabBarItemContentView(), title: "设置", image: UIImage(named: "设置-2"), selectedImage: UIImage(named: "设置-1"), tag: 2)
        
        viewControllers = [recordVC, runVC, settingVC]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func bloodPressureRecord() {
        let view = BloodWriteView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.show()
    }
    
    func heartRateDetection() {
//        let vc = enduranceFirstViewController()
//        let nav = NavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        AppDelegate.shareDelegate?.navigationController .present(nav, animated: true, completion: nil)
        let vc = HeartRateTipViewController()
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        AppDelegate.shareDelegate?.navigationController .present(nav, animated: true, completion: nil)
        
    }
    
    func temperatureRecord() {
        let view = TemperatureWriteView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.show()
    }

}

class TabBarItemContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        renderingMode = .alwaysOriginal
        itemContentMode = .alwaysOriginal
        textColor = .hex(0xCDCDCD)
        highlightTextColor = .hex(0x516FFF)
    }

    override func updateLayout() {
        super.updateLayout()
        titleLabel.font = .pingFangMedium(10)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TabBarItemCustomView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        renderingMode = .alwaysOriginal
        itemContentMode = .alwaysOriginal
        textColor = .hex(0xCDCDCD)
        highlightTextColor = .hex(0x516FFF)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    override func updateLayout() {
        super.updateLayout()
        self.imageView.sizeToFit()
        self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0 - 10)
    }

}
