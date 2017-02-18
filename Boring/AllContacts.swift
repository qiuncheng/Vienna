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

    static func getContacts(completion: Completion<[Contact]?>) {
        DispatchQueue.global().async {
            if let contacts = EMClient.shared().contactManager.getContacts() {
                print("All contacts is : \(contacts)")
                var results = [Contact]() {
                    didSet {
                        if results.count == contacts.count {
                            DispatchQueue.dispatchSafeQueue {
                                completion?(results)
                            }
                        }
                    }
                }
                let cacheHelper = CacheHelper()
                if contacts.count == 0 {
                    DispatchQueue.dispatchSafeQueue {
                        completion?(nil)
                    }
                    return
                }
                for contact in contacts {
                    if let _contact = contact as? String {
                        let subName = _contact.characters.count > 7 ? _contact.substring(to: _contact.index(_contact.startIndex, offsetBy: 2)) : _contact.substring(to: _contact.index(_contact.startIndex, offsetBy: 1))

                        cacheHelper.imageFromCache(appendKey: _contact, completion: { image in
                            if let _avatarImage = image {
                                let user = Contact(username: _contact, avatarImage: _avatarImage)
                                results.append(user)
                            }
                            else {
                                let _avatarimage = UIImage.init(text: subName, font: UIFont.systemFont(ofSize: 60), color: UIColor.random, backgroundColor: UIColor.random, size: CGSize(width: 80, height: 80), offset: CGPoint.zero)
                                let user = Contact.init(username: _contact, avatarImage: _avatarimage)
                                results.append(user)
                                cacheHelper.cacheImage(image: _avatarimage, appendKey: _contact)
                            }
                        })
                    }
                }
            }
        }
    }
}

struct CacheHelper {
    var cacheForContact: YYCache?
    var cacheQueue: DispatchQueue?
    
    init() {
        cacheQueue = DispatchQueue(label: "com.vsccw.cache.contact", qos: .default)
        if let pathStr = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let path = pathStr + "/cache_for_contact"
            let cache = YYCache.init(path: path)
            cache?.diskCache.costLimit = UInt(20 * 1024 * 1024)
            cache?.diskCache.ageLimit = TimeInterval(7 * 24 * 60 * 60)
            cache?.memoryCache.ageLimit = 5 * 60
            cache?.memoryCache.costLimit = UInt(5 * 1024 * 1024)
            cacheForContact = cache
        }
    }
    
    static var imageCacheKey: String {
        return "image_cache_for_contact"
    }
    
    func cacheImage(image: UIImage?, appendKey: String) {
        cacheQueue?.async {
            self.cacheForContact?.setObject(image, forKey: CacheHelper.imageCacheKey + appendKey)
        }
    }
    func imageFromCache(appendKey: String, completion: ((UIImage?) -> Void)?) {
        cacheQueue?.async {
            let image = self.cacheForContact?.object(forKey: CacheHelper.imageCacheKey + appendKey) as? UIImage
            DispatchQueue.main.async {
                completion?(image)
            }
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
