//
//  Message.swift
//  Boring
//
//  Created by 程庆春 on 2017/2/19.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

enum MessageOwner {
    case receiver
    case sender
    case unknown
}

enum MessageType {
    case text(String)
    case photo(UIImage)
}

enum ChatType {

}

struct Message {
    var originMessage: EMMessage?

    init(_ originMessage: EMMessage) {
        self.originMessage = originMessage
    }

    var content: String? {
        if let message = originMessage {
            switch message.body.type {
            case EMMessageBodyTypeText:
                return (message.body as! EMTextMessageBody).text
            default:
                return nil
            }
        }
        else {
            return nil
        }
    }

    var owner: MessageOwner {
        if let message = originMessage {
            switch message.direction {
            case EMMessageDirectionSend:
                return .sender
            case EMMessageDirectionReceive:
                return .receiver
            default:
                return .unknown
            }
        }
        else {
            return .unknown
        }
    }


}
