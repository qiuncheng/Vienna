//
//  UserDefaultable.swift
//  Boring
//
//  Created by yolo on 2017/2/15.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

protocol UserDefaultable {
    associatedtype UserDefaultKey: RawRepresentable
}

extension UserDefaultable where UserDefaultKey.RawValue == String {

    static func set(value: Bool, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func bool(forKey key: UserDefaultKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func set(value: Any?, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func object(forKey key: UserDefaultKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}

struct UserDefaultsHelper: UserDefaultable {
    enum UserDefaultKey: String {
        case loginSuccessful
        case userNameForLogin
        case passwordForLogin
    }
}
