//
//  HeartRateViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/25.
//

import UIKit
import Lottie

typealias HeartRateDetectionCompletion = (Int)->()

class HeartRateViewController: ViewController {

    @IBOutlet var backBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var animationLb: UILabel!
    var lotAnimationView = AnimationView()
    var isPop = false
    var animationTime = 0
    var timer = Timer()
    var rateArr = [NSNumber]()
    var firstErrorDate:Date?
    var completion:HeartRateDetectionCompletion? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPop {
            backBtn.setImage(UIImage(named: "fanhui-baise"), for: .normal)
        }
        addRateTimer()
        lotAnimationView = AnimationView.init(name: "jiance")
        lotAnimationView.loopMode = .playOnce
        lotAnimationView.animationSpeed = 2.0
        contentView.addSubview(lotAnimationView)
        lotAnimationView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        HeatBeatManager.sharedInstance().delegate = self
        HeatBeatManager.sharedInstance().start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.lotAnimationView.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.lotAnimationView.stop()
        }
    }

    func addRateTimer() {
        animationTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            self?.timerRun()
        })
    }
    
    func timerRun() {
        animationTime += 1
        guard let duration = lotAnimationView.animation?.duration else {
            //fatalError("???")
            return
        }
        if animationTime >= Int(floor(duration)/2) + 1 {
            HeatBeatManager.sharedInstance().stop()
            DispatchQueue.main.async {
                self.lotAnimationView.stop()
            }
            animationTime = 0
            timer.fireDate = Date.distantFuture
            timer.invalidate()
            if self.rateArr.count > 3 {
                let rate = calculationRate()
                if isPop {
                    //跳转到结果页面
                    let vc = HeartRateResultViewController()
                    vc.rateNum = rate
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    //返回数据给到耐力测试
                    self.completion?(rate)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }else {
                //视为检测不到手指的情况
                showRetryAlert()
            }
        }
    }
    
    func calculationRate() -> Int {
        var averageRate = 0
        for rate in rateArr {
            averageRate += rate.intValue
        }
        return averageRate/rateArr.count
    }
    
    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        showCancelAlert()
    }
    
    //检测不到手指的弹框
    func showRetryAlert() {
        let alert = UIAlertController.init(title: "检测不到手指", message: "请把手指按压紧", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (cancel) in
            DispatchQueue.main.async {
                if self.isPop {
                    self.navigationController?.popViewController(animated: true)
                }else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "重新检测", style: .default, handler: { (retry) in
            self.rateArr.removeAll()
            self.firstErrorDate = nil
            self.lotAnimationView.stop()
            self.lotAnimationView.play()
            self.addRateTimer()
            HeatBeatManager.sharedInstance().retry()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    //未检测完成就退出的提示弹框
    func showCancelAlert() {
        let alert = UIAlertController.init(title: "未检测完成", message: "确定退出吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (cancel) in
            
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (retry) in
            DispatchQueue.main.async {
                self.animationTime = 0
                self.timer.fireDate = Date.distantFuture
                self.timer.invalidate()
                self.firstErrorDate = nil
                HeatBeatManager.sharedInstance().stop()
                if self.isPop {
                    self.navigationController?.popViewController(animated: true)
                }else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    deinit {
        timer.fireDate = Date.distantFuture
        timer.invalidate()
    }
}

// MARK: - HeatBeatManagerDelegate
extension HeartRateViewController: HeatBeatManagerDelegate {
    func calculationTime() -> Bool {
        guard let firstErrorTime = self.firstErrorDate else {
            return false
        }
        let intervalTime:Double = Date().timeIntervalSinceReferenceDate - firstErrorTime.timeIntervalSinceReferenceDate
        if intervalTime < 5 {
            return false
        }else {
            return true
        }
    }
    
    func startHeartRateError(_ error: Error) {
        logInfo(error)
        if (error as NSError).code == 100 {
            //相机权限没开
            self.checkCamaraStatus { (grant) in
                if grant == false {
                    self.showNoAuthAlert()
                }
            }
        }
        if (error as NSError).code == 101 {
            guard self.firstErrorDate != nil else {
                self.firstErrorDate = Date()
                return
            }
            if self.calculationTime() {
                //持续5秒没检测到手指
                DispatchQueue.main.async {
                    self.lotAnimationView.stop()
                    HeatBeatManager.sharedInstance().stop()
                    self.animationTime = 0
                    self.timer.fireDate = Date.distantFuture
                    self.timer.invalidate()
                    self.showRetryAlert()
                }
            }
        }
    }
    
    func startHeartRateFrequency(_ frequency: Int) {
        if frequency > 0 {
            self.rateArr.append(frequency as NSNumber)
        }
    }
    
    func startHeartRateTip(_ tipStr: String) {
        DispatchQueue.main.async {
            if tipStr == "正在获取心率,请不要把手指移开！" {
                self.firstErrorDate = nil
            }
            self.animationLb.text = tipStr
        }
    }
}
