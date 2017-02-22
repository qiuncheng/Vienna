//
//  ChatViewController.swift
//  Boring
//
//  Created by 程庆春 on 2017/2/19.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import SnapKit

class ChatViewController: UIViewController, EMChatManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    var chatTarget: Contact?
    var messages: [Message]? = [Message]() {
        didSet {
            DispatchQueue.dispatchSafeQueue { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    var inputTextField: UITextField?
    var senderButton: UIButton?
    var conversation: EMConversation?

    lazy var inputBar: UIView = {
        let inputBar = UIView()
        inputBar.backgroundColor = UIColor.clear
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "请输入..."
        textField.delegate = self
        inputBar.addSubview(textField)
        self.inputTextField = textField

        let button = UIButton()
        button.setTitle("发送", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.addTarget(self, action: #selector(sendButtonClicked(button:)), for: .touchUpInside)
        inputBar.addSubview(button)

        self.senderButton = button

        return inputBar
    }()

    deinit {
        EMClient.shared().chatManager.remove(self)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self

        title = chatTarget?.username

        EMClient.shared().chatManager.add(self, delegateQueue: nil)
        let conversation = EMClient.shared().chatManager.getConversation(chatTarget!.username, type: EMConversationTypeChat, createIfNotExist: true)
        self.conversation = conversation
        conversation?.loadMessagesStart(fromId: nil, count: 10, searchDirection: EMMessageSearchDirectionUp, completion: { [weak self] (ms, error) in
            if error == nil {
                if let mmm = ms as? [EMMessage] {
                    for m in mmm {
                        let message = Message.init(m)
                        self?.messages?.append(message)
                    }
                }
            }
        })

        view.addSubview(inputBar)
        inputBar.snp.makeConstraints({
            $0.height.equalTo(30)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.snp.bottom)
        })

        senderButton?.snp.makeConstraints({
            $0.height.equalTo(inputBar.snp.height)
            $0.right.equalTo(inputBar.snp.right)
            $0.top.equalTo(inputBar.snp.top)
        })

        inputTextField?.snp.makeConstraints({
            $0.left.equalTo(inputBar.snp.left)
            $0.height.equalTo(inputBar.snp.height)
            $0.top.equalTo(inputBar.snp.top)
            $0.right.equalTo(senderButton!.snp.left)
        })

        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard)))

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // MARK: - Keyboard
    func keyboardWillShow(notification: Notification) {
        if let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            let height = frame.cgRectValue.height
            let _duration = duration.doubleValue
            UIView.animate(withDuration: _duration, animations: { 
                self.inputBar.transform = CGAffineTransform.init(translationX: 0, y: -height)
            }, completion: { [unowned self] (flag) in
                self.inputBar.snp.updateConstraints({
                    $0.bottom.equalTo(self.view.snp.bottom).offset(-height)
                })
                self.inputBar.transform = CGAffineTransform.identity
            })
            tableView.contentInset.bottom = height
        }
    }

    func keyboardWillHide(notification: Notification) {
        inputBar.snp.updateConstraints({
            $0.bottom.equalTo(view.snp.bottom)
        })
        tableView.contentInset.bottom = 49.0
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func sendButtonClicked(button: UIButton) {
        if let currentUsername = UserDefaultsHelper.object(forKey: .userNameForLogin) as? String,
            inputTextField?.text != nil,
            inputTextField?.text != "" {
            let body = EMTextMessageBody.init(text: inputTextField?.text)
            let message = EMMessage(conversationID: conversation?.conversationId, from: currentUsername, to: chatTarget?.username, body: body, ext: nil)
            EMClient.shared().chatManager.send(message, progress: nil, completion: { [weak self] (message, error) in
                if error == nil {
                    print("成功发送消息 ： \(message)")
                    self?.inputTextField?.text = ""
                    let message = Message.init(message!)
                    self?.messages?.append(message)
                }
            })
        }


    }

    @IBAction func showKeyboardButtonClicked(_ sender: UIBarButtonItem) {

    }

    // MARK: - EMChatManagerDelegate
    func messagesDidReceive(_ aMessages: [Any]!) {
        print("成功接收到消息 \(aMessages)")
        if let messages = aMessages as? [EMMessage] {
            for m in messages {
                let mmm = Message.init(m)
                self.messages?.append(mmm)
            }
        }
    }
    
    func messagesDidDeliver(_ aMessages: [Any]!) {
        print(aMessages)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = self.messages {
            return messages.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell")
        if let messages = self.messages {
            let mmm = messages[indexPath.row]
            if mmm.owner == .receiver {
                cell?.textLabel?.text = "『收到』\(mmm.content!)"
            }
            else {
                cell?.textLabel?.text = "『发出』\(mmm.content!)"
            }
        }
        return cell!
    }
}
