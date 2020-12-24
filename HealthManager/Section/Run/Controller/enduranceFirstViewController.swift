//
//  enduranceFirstViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/24.
//

import UIKit
import AVKit
import SnapKit

class VideoPlayer: UIView {

    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
}

class enduranceFirstViewController: ViewController {

    
    @IBOutlet var playerContentView: UIView!
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
    
    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func heartRateDetection(_ sender: Any) {
        self.resultView.isHidden = false
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let vc = EnduranceSecondViewController()
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
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
    
}
