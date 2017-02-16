//
//  AllContacts.swift
//  Boring
//
//  Created by 程庆春 on 2017/2/16.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit


struct Contact {
    var username: String?
    var avatarImage: UIImage?

    static func getContacts(completion: (([Contact]) -> Void)?) {
        DispatchQueue.global().async {
            if let contacts = EMClient.shared().contactManager.getContacts() {
                var results = [Contact]()
                for contact in contacts {
                    if let _contact = contact as? String {
                        let subName = _contact.characters.count > 7 ? _contact.substring(to: _contact.index(_contact.startIndex, offsetBy: 2)) : _contact.substring(to: _contact.index(_contact.startIndex, offsetBy: 1))
                        let user = Contact(username: _contact, avatarImage: UIImage.init(text: subName, font: UIFont.systemFont(ofSize: 60), color: UIColor.random, backgroundColor: UIColor.random, size: CGSize(width: 80, height: 80), offset: CGPoint.zero))
                        results.append(user)
                    }
                }
                DispatchQueue.dispatchSafeQueue {
                    completion?(results)
                }
            }
        }
    }
}

struct CacheHelper {
    var cache: YYCache?
    var cacheQueue: DispatchQueue?

}

extension UIColor {
    class var random: UIColor {
        let r = CGFloat(arc4random_uniform(256)) / 256.0
        let g = CGFloat(arc4random_uniform(256)) / 256.0
        let b = CGFloat(arc4random_uniform(256)) / 256.0
        return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
