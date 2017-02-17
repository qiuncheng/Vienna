//
//  AppDelegate.swift
//  Boring
//
//  Created by yolo on 2017/2/10.
//  Copyright © 2017年 Qiun Cheng. All rights reserved.
//

import UIKit
import PKHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let options = EMOptions(appkey: "1124170210115158#vsccw4boring2app")
        options?.enableConsoleLog = false
        options?.apnsCertName = "com_vsccw_app_Boring"
        options?.isAutoAcceptGroupInvitation = true
        options?.isAutoAcceptFriendInvitation = true
        
        EMClient.shared().initializeSDK(with: options)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let logined = UserDefaultsHelper.bool(forKey: .loginSuccessful)
        if logined {
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            window?.rootViewController = mainVC
        }
        else {
            window?.rootViewController = LoginViewController.loginVC
        }
        window?.makeKeyAndVisible()
        
        return true
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DispatchQueue.global().async {
            EMClient.shared().bindDeviceToken(deviceToken)
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        EMClient.shared().application(application, didReceiveRemoteNotification: userInfo)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("通知配置失败")
    }
}

