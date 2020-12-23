//
//  UserDefaultUtil.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/22.
//

import Foundation

let UserDefaultSavePrefix = "asdijl2lkjalskd"

@propertyWrapper
struct UserDefaultDoubleValue {
    let key: String
    let defaultValue: Double

    var wrappedValue: Double {
        get {
            let user = UserDefaults.standard
            return user.double(forKey: key + UserDefaultSavePrefix)
        }
        set {
            let user = UserDefaults.standard
            user.set(newValue, forKey: key + UserDefaultSavePrefix)
            user.synchronize()
        }
    }
}


@propertyWrapper
struct UserDefaultBoolValue {
    let key: String
    let defaultValue: Bool
    var wrappedValue: Bool {
        get {
            let user = UserDefaults.standard
            return user.bool(forKey: key + UserDefaultSavePrefix)
        }
        set {
            let user = UserDefaults.standard
            user.set(newValue, forKey: key + UserDefaultSavePrefix)
            user.synchronize()
        }
    }
}

@propertyWrapper
struct UserDefaultIntValue {
    let key: String
    let defaultValue: Int
    var wrappedValue: Int {
        get {
            let user = UserDefaults.standard
            return user.integer(forKey: key + UserDefaultSavePrefix)
        }
        set {
            let user = UserDefaults.standard
            user.set(newValue, forKey: key + UserDefaultSavePrefix)
            user.synchronize()
        }
    }
}


@propertyWrapper
struct UserDefaultStringValue {
    let key: String
    let defaultValue: String
    var wrappedValue: String {
        get {
            let user = UserDefaults.standard
            guard let value = user.string(forKey: key + UserDefaultSavePrefix) else {
                return defaultValue
            }
            return value
        }
        set {
            let user = UserDefaults.standard
            user.set(newValue, forKey: key + UserDefaultSavePrefix)
            user.synchronize()
        }
    }
}

