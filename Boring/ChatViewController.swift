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

    let inputBarHeight: CGFloat = 40.0
    
    @IBOutlet weak var tableView: UITableView!
    var chatTarget: Contact?
    var oldCount: Int!
    var messages: [Message]? = [Message]() {
        willSet {
            oldCount = messages!.count
        }
        didSet {
            DispatchQueue.dispatchSafeQueue { [unowned self] in
                let newCount = self.messages!.count
                var indexPaths = [IndexPath]()
                if newCount > self.oldCount {
                    for i in self.oldCount ..< newCount {
                        let indexPath = IndexPath(row: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self.tableView.reloadData()
//                    self.tableView.beginUpdates()
//                    self.tableView.insertRows(at: indexPaths, with: .bottom)
//                    self.tableView.endUpdates()
                    self.tableViewScrollToBottom()
                }
            }
        }
    }

    var inputTextField: UITextField?
    var senderButton: UIButton?
    var conversation: EMConversation?

    lazy var inputBar: UIView = {
        let inputBar = UIView()
        inputBar.backgroundColor = UIColor.white
        let textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "请输入..."
        textField.returnKeyType = .send
        textField.delegate = self
        inputBar.addSubview(textField)
        self.inputTextField = textField

        let button = UIButton()
        button.setTitle("发送", for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
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
        tableView.contentInset.bottom = inputBarHeight
        tableView.keyboardDismissMode = .onDrag

        title = chatTarget?.username

        EMClient.shared().chatManager.add(self, delegateQueue: nil)
        let conversation = EMClient.shared().chatManager.getConversation(chatTarget!.username, type: EMConversationTypeChat, createIfNotExist: true)
        self.conversation = conversation
        conversation?.loadMessagesStart(fromId: nil, count: 20, searchDirection: EMMessageSearchDirectionUp, completion: { [weak self] (msg, error) in
            if error == nil {
                if let emMessages = msg as? [EMMessage] {
                    for m in emMessages {
                        let message = Message(m)
                        self?.messages?.append(message)
                    }
                }
            }
        })

        view.addSubview(inputBar)
        inputBar.snp.makeConstraints({
            $0.height.equalTo(inputBarHeight)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.snp.bottom)
        })

        senderButton?.snp.makeConstraints({
            $0.height.equalTo(inputBar.snp.height).offset(-6)
            $0.right.equalTo(inputBar.snp.right).offset(-3)
            $0.width.equalTo(60)
            $0.top.equalTo(inputBar.snp.top).offset(3)
        })

        inputTextField?.snp.makeConstraints({
            $0.left.equalTo(inputBar.snp.left).offset(5)
            $0.height.equalTo(inputBar.snp.height)
            $0.top.equalTo(inputBar.snp.top)
            $0.right.equalTo(senderButton!.snp.left)
        })

        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard)))

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
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
            tableView.contentInset.bottom = height + inputBarHeight
            tableViewScrollToBottom()
        }
    }

    func keyboardWillHide(notification: Notification) {
        inputBar.snp.updateConstraints({
            $0.bottom.equalTo(view.snp.bottom)
        })
        tableView.contentInset.bottom = inputBarHeight
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
            EMClient.shared().chatManager.send(message, progress: nil, completion: { [weak self] (msg, error) in
                if error == nil {
                    self?.inputTextField?.text = ""
                    let mmm = Message(msg!)
                    self?.messages?.append(mmm)
                }
            })
        }
    }
    
    // MARK: - ScrollToBottom
    func tableViewScrollToBottom() {
        if messages!.count > 0 {
            if let msgs = messages {
                let indexPath = IndexPath(row: msgs.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    // MARK: - Cell MAX Width
    func textHeight(with text: String) -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 30
        let size = text.boundingRect(
            with: CGSize.init(width: maxWidth, height: 150),
            options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading,] ,
            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)],
            context: nil)
        return size.height
    }
    
    // MARK: - EMChatManagerDelegate
    func messagesDidReceive(_ aMessages: [Any]!) {
        if let emMessages = aMessages as? [EMMessage] {
            for message in emMessages {
                let message = Message(message)
                self.messages?.append(message)
            }
        }
    }
    
    func messagesDidDeliver(_ aMessages: [Any]!) {
        print(aMessages)
    }
}

extension ChatViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonClicked(button: senderButton!)
        return true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? ChatTextCell
        if let messages = self.messages {
            let mmm = messages[indexPath.row]
            cell?.message = mmm
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let text = messages?[indexPath.row].content {
            return textHeight(with: text) + 20
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
