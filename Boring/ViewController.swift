//
//  ViewController.swift
//  Boring
//
//  Created by yolo on 2017/2/10.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import PKHUD


class ViewController: UIViewController, EMContactManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var contacts: [Contact]? {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Actions
    @IBAction func logoutButtonClicked(_ sender: Any) {

        DispatchQueue.global().async {
            guard let _ = EMClient.shared().logout(false) else {
                DispatchQueue.dispatchSafeQueue {
                    UserDefaultsHelper.set(value: false, forKey: .loginSuccessful)
                    UIApplication.shared.keyWindow?.rootViewController = LoginViewController.loginVC
                }
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = #imageLiteral(resourceName: "icon")
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.addNewContact))
        imageView.addGestureRecognizer(tap)
        let leftItem = UIBarButtonItem(customView: imageView)
        navigationItem.leftBarButtonItem = leftItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        
        if let username = UserDefaultsHelper.object(forKey: .userNameForLogin) as? String {
            title = username
        }
        
        EMClient.shared().contactManager.add(self, delegateQueue: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getContacts()
    }

    deinit {
        EMClient.shared().contactManager.removeDelegate(self)
    }

    fileprivate func getContacts() {
        Contact.getContacts { [weak self] results in
            guard let _results = results else {
                self?.contacts = [Contact]()
                return
            }
            self?.contacts = _results
        }
    }

    @objc fileprivate func addNewContact() {
        let alertController = UIAlertController.init(title: "添加好友", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "请输入好友ID"
        }
        alertController.addTextField { (textField) in
            textField.text = "我想加你好友."
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction.init(title: "发送", style: .destructive, handler: { _ in
            if let firstTextField = alertController.textFields?.first,
                let text = firstTextField.text,
                text.characters.count > 0,
                let secondTextField = alertController.textFields?.last,
                let helloText = secondTextField.text {
                DispatchQueue.global().async {
                    let error = EMClient.shared().contactManager.addContact(text, message: helloText)
                    if error != nil {
                        print("发送失败： \(error?.code) \(error.debugDescription) - \(error?.errorDescription)")
                    }
                    else {
                        print("请求已发送")
                    }
                }

            }
        }))
        present(alertController, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func friendshipDidAdd(byUser aUsername: String!) {
        HUD.flash(.label("添加『\(aUsername!)』好友成功"), onView: view, delay: 1.0, completion: nil)
        getContacts()
    }

    func friendshipDidRemove(byUser aUsername: String!) {
        HUD.flash(.label("删除『\(aUsername!)』好友成功"), onView: view, delay: 1.0, completion: nil)
        getContacts()
    }

    func friendRequestDidApprove(byUser aUsername: String!) {
        HUD.flash(.label("对方同意你的好友申请"), onView: view, delay: 1.0, completion: nil)
    }

    func friendRequestDidDecline(byUser aUsername: String!) {
        HUD.flash(.label("对方拒绝你的好友申请"), onView: view, delay: 1.0, completion: nil)
    }

    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        print(aUsername + aMessage)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = contacts {
            return results.count
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatCell.cellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell {
            if let results = contacts {
                cell.avatarImageView?.image = results[indexPath.row].avatarImage
                cell.nameLabel?.text = results[indexPath.row].username
            }
            return cell
        }
        else {
            let cell = ChatCell.init(style: .default, reuseIdentifier: ChatCell.identifier)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction.init(style: .destructive, title: "删除") { [weak self] (action, indexPath) in
            if let contact = self?.contacts?[indexPath.row] {
                DispatchQueue.global().async {
                    let error = EMClient.shared().contactManager.deleteContact(contact.username, isDeleteConversation: true)
                    print("Error when delete friend: \(error?.errorDescription)")
                }
            }
        }
        return [deleteAction]
    }
}

