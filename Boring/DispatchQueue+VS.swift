//
//  Common.swift
//  Boring
//
//  Created by yolo on 2017/2/15.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit


extension DispatchQueue {
    static func dispatchSafeQueue(block: ((Void) -> Void)?) {
        if Thread.isMainThread {
            block?()
        }
        else {
            DispatchQueue.main.async {
                block?()
            }
        }
    }
}
