//
//  LoginViewController.swift
//  Boring
//
//  Created by yolo on 2017/2/14.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard usernameTextField.text != nil,
            passwordTextField.text != nil else {
                return
        }
        let loginError = EMClient.shared().login(withUsername: usernameTextField.text, password: passwordTextField.text)
        if let error = loginError,
            error.code.rawValue == 204 {
            let registerError = EMClient.shared().register(withUsername: usernameTextField.text, password: passwordTextField.text)
            if registerError == nil {
                EMClient.shared().login(withUsername: usernameTextField.text, password: passwordTextField.text)
                let tabVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = tabVC
            }
        }
        else {
            let tabVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = tabVC
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
