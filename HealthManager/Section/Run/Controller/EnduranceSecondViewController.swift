//
//  EnduranceSecondViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit
import AVKit

class EnduranceSecondViewController: ViewController {

    
    @IBOutlet var playerContentView: UIView!
    @IBOutlet var timeLb: UILabel!
    @IBOutlet var infoLb: UILabel!
    @IBOutlet var sportEndView: UIView!
    @IBOutlet var resultView: UIView!
    @IBOutlet var heartRateLb: UILabel!
    @IBOutlet var colorLb: UILabel!
    var rateSum:Int = 0 //心率总和
    
    
    private var avplayer: AVPlayer!
    private var videoView: VideoPlayer! // 显示的视频
    private var playerItem: AVPlayerItem!
    
    @UserDefaultBoolValue(key: "detectionShowTip", defaultValue: false)
    var detectionShowTip
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let str = "站立，双脚分开(同肩宽),双臂前伸,在45秒内要双腿弯曲30次,感觉就像你刚挨着凳子立即又站起来。"
        let attStr:NSMutableAttributedString = NSMutableAttributedString(string: str)
        let range1:NSRange = (str as NSString).range(of: "45秒")
        let range2:NSRange = (str as NSString).range(of: "30次")
        attStr.addAttribute(NSAttributedString.Key.font, value: UIFont.pingFangSemibold(18), range: range1)
        attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.hex(0x5B79FF), range: range1)
        attStr.addAttribute(NSAttributedString.Key.font, value: UIFont.pingFangSemibold(18), range: range2)
        attStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.hex(0x5B79FF), range: range2)
        self.infoLb.attributedText = attStr
        
        let videoView = VideoPlayer()
        self.videoView = videoView
        videoView.backgroundColor = .clear
        self.playerContentView.addSubview(videoView)
        videoView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let path = Bundle.main.path(forResource: "运动视频", ofType: "mp4")
        let url = URL(fileURLWithPath: path ?? "")
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        // 监听它状态的改变,实现kvo的方法
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.avplayer = AVPlayer(playerItem: playerItem)
        if let playerLayer = videoView.layer as? AVPlayerLayer {
            playerLayer.player = avplayer
        }
        /// 播放结束的通知.
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
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
        }))
        alert.addAction(UIAlertAction(title: "好了", style: .default, handler: { (retry) in
            let vc = HeartRateViewController()
            vc.isPop = false
            vc.completion = { rate in
                self.resultView.isHidden = false
                self.heartRateLb.text = String(format: "%d", rate)
                self.rateSum += rate
                if rate < 90 {
                    self.colorLb.text = "心率过缓"
                    self.colorLb.textColor = .hex(0x6986DC)
                }else if rate > 130 {
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


    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func startTimeAction(_ sender: UIButton) {
        sender.isHidden = true
        self.dispatchTimer(timeInterval: 1, repeatCount: 45) { (time, count) in
            self.timeLb.text = "\(count)"
            if count == 0 {
                self.sportEndView.isHidden = false
            }
        }
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
                        if rate < 90 {
                            self.colorLb.text = "心率过缓"
                            self.colorLb.textColor = .hex(0x6986DC)
                        }else if rate > 130 {
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
        let vc = EnduranceThirdViewController()
        vc.rateSum = self.rateSum
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "status" {
            // 资源准备好, 可以播放
            if playerItem.status == .readyToPlay {
                self.avplayer.play()
            } else {
                print("load error")
            }
        }
    }
    
    // 播放完成
    @objc func playToEndTime() {
        self.playerItem.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale.init(1))) { (success) in
            self.avplayer.play()
        }
    }
    
    func dispatchTimer(timeInterval: Double, repeatCount: Int, handler: @escaping (DispatchSourceTimer?, Int) -> Void) {
            
        if repeatCount <= 0 {
            return
        }
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        var count = repeatCount
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count == 0 {
                timer.cancel()
            }
        }
        timer.resume()
            
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }

}
