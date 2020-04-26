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
import FirebaseUI

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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.devwilfred.addlist" {
            guard let rootView = window?.rootViewController as? UINavigationController else { return }
            guard rootView.viewControllers.count > 1
                else {
                    // not logged in / current screen is auth controller
                    return
            }
            guard let tabController = rootView.viewControllers[1] as? UITabBarController,
                let firstTab = tabController.viewControllers?.first as? UINavigationController else { return }
            tabController.selectedIndex = 0
            firstTab.popToRootViewController(animated: true)
            let allListsView = firstTab.viewControllers.first as? AllListsViewController
            allListsView?.performSegue(withIdentifier: "listDetailSegue", sender: nil)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
          return true
        }
        // other URL handling goes here.
        return false
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

