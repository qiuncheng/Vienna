//
//  LoginViewController.swift
//  Boring
//
//  Created by yolo on 2017/2/14.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import PKHUD
import UserNotifications

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usernameTextField: UITextField!
    var loginQueue: DispatchQueue?
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let queue = DispatchQueue(label: "com.vsccw.boring.login")
        self.loginQueue = queue
        
        if let username = UserDefaultsHelper.object(forKey: .userNameForLogin) as? String {
            usernameTextField.text = username
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        registerNotification()
    }

    func registerNotification() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    application.registerForRemoteNotifications()
                }
            }
            return ;
        } else {
            // Fallback on earlier versions
            if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
                let settings = UIUserNotificationSettings.init(types: [.badge, .sound, .alert], categories: nil)
                application .registerUserNotificationSettings(settings)
            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    class var loginVC: LoginViewController? {
        return UIStoryboard.init(name: "Login", bundle: nil).instantiateInitialViewController() as? LoginViewController
    }
    
    // MARK: - Actions
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard usernameTextField.text != nil,
            passwordTextField.text != nil,
            usernameTextField.text != "",
            passwordTextField.text != "" else {
                return
        }
        view.endEditing(true)
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show(onView: view)
        loginQueue?.async { [unowned self] in
            let loginError = EMClient.shared().login(withUsername: self.usernameTextField.text, password: self.passwordTextField.text)
            if let error = loginError,
                error.code.rawValue == 204 {
                let registerError = EMClient.shared().register(withUsername: self.usernameTextField.text, password: self.passwordTextField.text)
                if registerError == nil {
                    EMClient.shared().login(withUsername: self.usernameTextField.text, password: self.passwordTextField.text)
                    EMClient.shared().options.isAutoLogin = true
                    DispatchQueue.dispatchSafeQueue {
                        let tabVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = tabVC
                    }
                }
                DispatchQueue.dispatchSafeQueue {
                    PKHUD.sharedHUD.hide()
                }
            }
            else {
                EMClient.shared().options.isAutoLogin = true
                DispatchQueue.dispatchSafeQueue {
                    let tabVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = tabVC
                    PKHUD.sharedHUD.hide()
                }
            }
            
        }
        UserDefaultsHelper.set(value: usernameTextField.text, forKey: .userNameForLogin)
        UserDefaultsHelper.set(value: passwordTextField.text, forKey: .passwordForLogin)
        UserDefaultsHelper.set(value: true, forKey: .loginSuccessful)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
