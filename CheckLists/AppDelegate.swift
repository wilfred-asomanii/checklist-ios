//
//  AppDelegate.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var fireAuth: FirebaseAuth.Auth?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let controller = window?.rootViewController as? UINavigationController
        let authViewController = controller?.viewControllers.first as? AuthViewController
        authViewController?.authController = AuthController()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK:- user notification delegates

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        guard let itemID = userInfo["itemID"], let listID = userInfo["listID"] else {
            completionHandler()
            return
        }

        let rootView = window?.rootViewController as? UINavigationController
        let tabController = rootView?.viewControllers[1] as? UITabBarController
        tabController?.selectedIndex = 0
        let firstTab = tabController?.viewControllers?.first as? UINavigationController
        let allListsView = firstTab?.viewControllers.first as? AllListsViewController
        allListsView?.notificationTapped(for: itemID as! String, in: listID as! String)

        completionHandler()
    }
}

