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
        
        EMClient.shared().initializeSDK(with: options)
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show(onView: self.window)
        let registerError = EMClient.shared().register(withUsername: "12345", password: "123456abc")
        
        /// 登录操作
        func login() {
            let loginError = EMClient.shared().login(withUsername: "12345", password: "123456abc")
            PKHUD.sharedHUD.hide()
            if loginError != nil {
                print("登录失败\(loginError?.errorDescription)")
            }
            else {
                print("登录成功")
            }
        }
        
        if registerError != nil {
            print("注册失败: \(registerError)")
            if registerError!.code == EMErrorUserAlreadyExist {
                login()
            }
            
        } else {
            print("注册成功")
            login()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
