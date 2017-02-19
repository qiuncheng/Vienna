//
//  ReceiverCell.swift
//  Boring
//
//  Created by 程庆春 on 2017/2/19.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

class ReceiverCell: UITableViewCell {

    var avatarImageView: UIImageView?
    fileprivate var background: UIView?
    var contentLabel: UILabel?

    var message: Message? {
        didSet {

        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
