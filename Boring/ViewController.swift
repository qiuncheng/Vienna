//
//  ViewController.swift
//  Boring
//
//  Created by yolo on 2017/2/10.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Actions
    @IBAction func logoutButtonClicked(_ sender: Any) {
        UserDefaultsHelper.set(value: false, forKey: .loginSuccessful)
        
        UIApplication.shared.keyWindow?.rootViewController = LoginViewController.loginVC
        
        DispatchQueue.global().async {
            EMClient.shared().logout(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = #imageLiteral(resourceName: "icon")
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        let leftItem = UIBarButtonItem(customView: imageView)
        navigationItem.leftBarButtonItem = leftItem
        
        if let username = UserDefaultsHelper.object(forKey: .userNameForLogin) as? String {
            title = username
        }
        
        EMClient.shared().contactManager.addContact("eee", message: "我想加你好友！")
        EMClient.shared().contactManager.acceptInvitation(forUsername: "eeee")
        let contacts = EMClient.shared().contactManager.getContacts()
        print(contacts)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

