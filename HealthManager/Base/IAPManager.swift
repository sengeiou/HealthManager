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
    
    @UserDefaultBoolValue(key: "isForeverVIP", defaultValue: false)
    var isForeverVIP

    var purchased: Bool {
        return isForeverVIP
    }


    func purchase(_ productInfo:String, completion: @escaping ((Bool, String) -> Void)) {
        SwiftyStoreKit.purchaseProduct(productInfo) { result in
            switch result {
            case .success(let purchase):
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verifyPurchases(with: [Purchase(productId: purchase.productId, quantity: purchase.quantity, transaction: purchase.transaction, originalTransaction: purchase.originalTransaction, needsFinishTransaction: purchase.needsFinishTransaction)], completion: completion, isRestore: false)
            case .error(let error):
                switch error.code {
                case .paymentCancelled:
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
                self.verifyPurchases(with: restoreResults.restoredPurchases, completion: completion, isRestore: true)
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
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    print("error: \(purchase)")
                @unknown default:
                    break // do nothing
                }
            }
            self.verifyPurchases(with: purchases, completion: nil, isRestore: false)
        }
    }

    func verifyPurchases(with purchases:[Purchase], completion: ((Bool, String) -> Void)? , isRestore:Bool) {
        for item in purchases {
            if item.transaction.transactionState == .purchased || item.transaction.transactionState == .restored {
                if item.productId == InAppPurchasesYearKey {
                    self.isForeverVIP = true;
                    statistical(item, isRestore: isRestore)
                    completion?(true, "")
                    return;
                }
            }
        }
        completion?(false, "购买失败")
    }
    
    func statistical(_ info: Purchase, isRestore:Bool) {
        let key = info.productId
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()
            if !isRestore {
                MobClick.event("vip_num")
            }else{
                MobClick.event("restore_num")
            }
        }
    }
}
