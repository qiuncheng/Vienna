//
//  Common.swift
//  Boring
//
//  Created by yolo on 2017/2/15.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit


extension DispatchQueue {
    static func dispatchSafeQueue(_ handler: Completion<Void>) {
        if Thread.isMainThread {
            handler?()
        }
        else {
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
}
