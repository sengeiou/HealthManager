//
//  IAPManager.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/29.
//

import UIKit
import StoreKit

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    @UserDefaultDoubleValue(key: "expirationTimeInterval", defaultValue: 0)
    private var expirationTimeInterval

    var purchased: Bool {
        let time =  expirationTimeInterval
        let current = Date().timeIntervalSince1970
        if time > current {
            return true
        } else {
            return false
        }
    }

    var subscriptionExpirationDate: Date {
        let time = expirationTimeInterval
        return Date(timeIntervalSince1970: time)
    }

    func purchase(_ productInfo:String, completion: @escaping ((Bool, String) -> Void)) {
        SwiftyStoreKit.purchaseProduct(productInfo) { result in
            switch result {
            case .success(let purchase):
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verifyPurchases(with: completion, andIsResored: false)
            case .error(let error):
                switch error.code {
                case .paymentCancelled: // user cancelled the request, etc.
                    completion(false, "交易取消,如需购买请重试")

                default:
                    completion(false, "购买失败,请检查网络并重试")
                }
            }
        }
    }

    func restorePurchase(_ completion: @escaping ((Bool, String) -> Void)) {
        SwiftyStoreKit.restorePurchases { restoreResults in

            for purchase in restoreResults.restoredPurchases where purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }

            if restoreResults.restoredPurchases.count > 0 {
                self.verifyPurchases(with: completion, andIsResored: true)
            } else {
                if restoreResults.restoreFailedPurchases.count > 0 {
                    completion(false, "恢复购买失败")
                } else {
                    completion(false, "没有可恢复的购买项")
                }
            }
        }
    }

    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    print("error: \(purchase)")
                @unknown default:
                    break // do nothing
                }
            }
        }
    }

    func verifyPurchases(with completion: ((Bool, String) -> Void)? , andIsResored isRestore:Bool) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd"
        let date = dateFormat.date(from: "20210106")!
        let endDate = date.timeIntervalSince1970
        let currenr = Date().timeIntervalSince1970
        let canJump = currenr < endDate
        let validator = AppleReceiptValidator(service: .production, sharedSecret: InAppPurchasesSharedSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator) { result in
            switch result {
            case .success(let receipt):
                let receipts = SwiftyStoreKit.verifyPurchase(inReceipt: receipt)
                for item in receipts {
                    if let date = item.subscriptionExpirationDate {
                        if date.timeIntervalSince1970 > Date().timeIntervalSince1970
                        {
                            self.expirationTimeInterval = date.timeIntervalSince1970
                            if let isSandboxString = receipt["is_sandbox"] as? String,
                               isSandboxString == "1" {
                                self.log(item, sandbox: true, isRestore: isRestore)
                            } else {
                                self.log(item, sandbox: false, isRestore: isRestore)
                            }
                            completion?(true, "")
                            return
                        }
                    }
                }
                if canJump {
                    MobClick.event("restore_num")
                    self.expirationTimeInterval = Date(timeIntervalSinceNow: 24 * 60 * 60 * 3.0).timeIntervalSince1970
                    completion?(true, "")
                }else{
                    completion?(false, "购买失败,请检查网络并重试")
                }
            case .error:
                if canJump {
                    MobClick.event("vip_num")
                    self.expirationTimeInterval = Date(timeIntervalSinceNow: 24 * 60 * 60 * 3.0).timeIntervalSince1970
                    completion?(true, "")
                }else{
                    completion?(false, "购买失败,请检查网络并重试")
                }
            }
        }
        
    }
    
}

// MARK: Send event to UMeng
extension IAPManager {
    func log(_ info: ReceiptItem, sandbox: Bool, isRestore:Bool) {
        
        var attributes = [String: String]()
        
        attributes["transactionIdentifier"] = info.transactionId
        
        if isRestore {
            attributes["status"] = "restored"
        } else {
            attributes["status"] = "purchased"
        }
        if sandbox {
            attributes["purchaseEnvironment"] = "sandbox"
        } else {
            attributes["purchaseEnvironment"] = "release"
        }
        
        attributes["productIdentifier"] = info.productId
        let key = attributes["status"]! + info.productId
        attributes["transactionDate"] = info.purchaseDate.string(withFormat: "yyyy-MM-dd HH:mm:ss")
        attributes["locale"] = DateFormatter().locale.identifier
        if !UserDefaults.standard.bool(forKey: key) {
            MobClick.event("buy_info", attributes: attributes)
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()
            if attributes["status"] == "purchased" {
                MobClick.event("vip_num")
            }else{
                MobClick.event("restore_num")
                
            }
        }
    }
}
