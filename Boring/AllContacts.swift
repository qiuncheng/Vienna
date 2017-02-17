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
    var cacheForContact: YYCache? {
        if let pathStr = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let path = pathStr + "cache_for_contact"
            let cache = YYCache.init(path: path)
            cache?.diskCache.costLimit = UInt(20 * 1024 * 1024)
            cache?.diskCache.ageLimit = TimeInterval(7 * 24 * 60 * 60)
            cache?.memoryCache.ageLimit = 5 * 60
            cache?.memoryCache.costLimit = UInt(5 * 1024 * 1024)
            return cache
        }
        return nil
    }
    var cacheQueue: DispatchQueue?
    
    init() {
        cacheQueue = DispatchQueue(label: "com.vsccw.cache.contact", qos: .default)
    }
    
    static var imageCacheKey: String {
        return "image_cache_for_contact"
    }
    
    func cacheImage(image: UIImage) {
        cacheQueue?.async {
            self.cacheForContact?.setObject(image, forKey: CacheHelper.imageCacheKey)
        }
    }
    func imageFromCache(completion: ((UIImage?) -> Void)?) {
        cacheQueue?.async {
            let image = self.cacheForContact?.object(forKey: CacheHelper.imageCacheKey) as? UIImage
            completion?(image)
        }
    }
    
}

extension UIColor {
    class var random: UIColor {
        let r = CGFloat(arc4random_uniform(256)) / 256.0
        let g = CGFloat(arc4random_uniform(256)) / 256.0
        let b = CGFloat(arc4random_uniform(256)) / 256.0
        return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
