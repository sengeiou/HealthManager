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
    
    
    private var avplayer: AVPlayer!
    private var videoView: VideoPlayer! // 显示的视频
    private var playerItem: AVPlayerItem!
    
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
        self.resultView.isHidden = false
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let vc = EnduranceThirdViewController()
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
