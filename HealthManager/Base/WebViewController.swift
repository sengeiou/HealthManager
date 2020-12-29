//
//  WebViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/29.
//

import UIKit
import WebKit
import SwifterSwift
import SnapKit

class WebViewController: ViewController {

    var url: URL?
    
    init(title: String? = nil, url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contentView: WKWebView = {
        let wv = WKWebView(frame: view.bounds)
        return wv
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .hex(0xFFFFFF)
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.setImage(UIImage(named: "返回"), for: .normal)
        button.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        button.addTarget(self, action: #selector(pressedBackButton(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.text = self.title
        label.textColor = UIColor(hex: 0x000000)
        label.textAlignment = .center
        label.font = UIFont.pingFangSemibold(15)
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(CGSize(width: 200, height: 44))
        }
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        if let url = self.url {
            contentView.load(URLRequest(url: url))
        }
    }
    

    @objc func pressedBackButton(_ button:UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
