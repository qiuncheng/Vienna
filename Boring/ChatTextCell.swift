//
//  ChatTextCell.swift
//  Boring
//
//  Created by yolo on 2017/2/24.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

class ChatTextCell: UITableViewCell {
    @IBOutlet weak var textMessageLabel: UILabel!
    
    var message: Message! {
        didSet {
            if message.owner == .receiver {
                textMessageLabel.text = "『收到』\(message.content!)"
            }
            else {
                textMessageLabel.text = "『发出』\(message.content!)"
            }
        }
    }
}
