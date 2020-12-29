//
//  Defines.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import Foundation
import SnapKit
import SwifterSwift
import FileKit

let InAppPurchasesSharedSecretKey = ""
let InAppPurchasesYearKey = ""
let AppInStoreID = ""
let UMengAppKey = "5fe03d140b4a4938464c7daa"

let UserURL = "https://www.baidu.com"
let PrivacyURL = "https://www.baidu.com"

let screenWidth:CGFloat = UIScreen.main.bounds.size.width
let screenHeight:CGFloat = UIScreen.main.bounds.size.height

enum APP {
    static let appDownloadUrl = "https://itunes.apple.com/cn/app/id\(AppInStoreID)?mt=8"
    static let appDisplayName = UIApplication.shared.displayName ?? ""
    static let appVersion = UIApplication.shared.version ?? ""
    static let bundleID:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
    
    static let isIphoneX:Bool = {
        return AppDelegate.shareDelegate!.window!.safeAreaInsets.bottom > 0
    }()
    
    static let ruffierChanged = Notification.Name("HM.ruffierChanged")
    ///心率血压体温数据发生变化
    static let homeDateChanged = Notification.Name("HM.homeDateChanged")
    
    static let hmFilesPath: Path = {
        let path = Path.userDocuments + "hmFiles"
        if !path.exists {
            do {
                try path.createDirectory()
            } catch {
                logError(error)
            }
        }
        return path
    }()
}

#if DEBUG

func logInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NSLog("%@:%zd %@", fileName, line, function)
    print("⚪️: ", terminator: "")
    debugPrint(message)
}

func logError<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NSLog("%@:%zd %@", fileName, line, function)
    print("🔴: ", terminator: "")
    debugPrint(message)
}

#else

func logInfo<T>(_ msggg: T, prefixxxx: String = "[I]") {}
func logError<T>(_ msggg: T, prefixxxx: String = "[E]") {}

#endif

func setViewRadius(view: UIView, corners: UIRectCorner, cornerRadius: CGFloat) {
    let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.layer.bounds
    maskLayer.path = maskPath.cgPath
    view.layer.mask = maskLayer
}

// MARK: Extensions
extension UIColor {
    static func hex(_ hex: Int, transparency:CGFloat = 1.0) -> UIColor {
        return UIColor(hex: hex, transparency: transparency) ?? .white
    }
}

extension UIFont {
    static func pingFangRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func pingFangMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func pingFangSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
