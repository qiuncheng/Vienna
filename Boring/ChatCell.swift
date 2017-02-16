//
//  ChatCell.swift
//  Boring
//
//  Created by yolo on 2017/2/16.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import SnapKit

class ChatCell: UITableViewCell {
    
    var avatarImageView: AvatarImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return "ChatCell"
    }
    
    static var cellHeight: CGFloat {
        return 100.0
    }
    
    fileprivate func setupUI() {
        let _avatarImageView = AvatarImageView.init(text: "H", frame: CGRect.zero)
        _avatarImageView.layer.cornerRadius = 40
        _avatarImageView.layer.masksToBounds = true
        addSubview(_avatarImageView)
        self.avatarImageView = _avatarImageView
        
        applyConstraints()
    }
    
    fileprivate func applyConstraints() {
        avatarImageView?.snp.makeConstraints({
            $0.left.equalTo(snp.left).offset(10)
            $0.top.equalTo(snp.top).offset(10)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
