//
//  HeartRateTipViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/25.
//

import UIKit
import AVKit

class HeartRateTipViewController: ViewController {

    @IBOutlet var playerContentView: UIView!
    private var avplayer: AVPlayer!
    private var videoView: VideoPlayer! // 显示的视频
    private var playerItem: AVPlayerItem!
    
    @UserDefaultBoolValue(key: "detectionShowTip", defaultValue: false)
    var detectionShowTip
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoView = VideoPlayer()
        self.videoView = videoView
        videoView.backgroundColor = .clear
        self.playerContentView.addSubview(videoView)
        videoView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let path = Bundle.main.path(forResource: "手指动画", ofType: "mp4")
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
    
    //检测不到手指的弹框
    func showTipAlert() {
        let alert = UIAlertController.init(title: "手指放置好了吗？", message: "请确认", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "不再提示", style: .default, handler: { (cancel) in
            self.detectionShowTip = true
        }))
        alert.addAction(UIAlertAction(title: "好了", style: .default, handler: { (retry) in
            let vc = HeartRateViewController()
            vc.isPop = true
            self.navigationController?.pushViewController(vc, animated: true)
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


    //MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func detectionAction(_ sender: Any) {
        self.checkCamaraStatus { (grant) in
            if grant == false {
                self.showNoAuthAlert()
                return
            }else {
                if self.detectionShowTip {
                    let vc = HeartRateViewController()
                    vc.isPop = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    self.showTipAlert()
                }
            }
        }
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
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
    
}
