//
//  AvatarImageView.swift
//  Boring
//
//  Created by yolo on 2017/2/16.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import ImageHelper

class AvatarImageView: UIImageView {
    
    convenience init(text: String, frame: CGRect) {
        self.init(frame: frame)
        let _image = UIImage.init(text: text, font: UIFont.systemFont(ofSize: 48), color: UIColor.blue, backgroundColor: UIColor.cyan, size: CGSize.init(width: 80, height: 80), offset: CGPoint.zero)
        
        self.image = _image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
  
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("error when acoder.")
    }
}
