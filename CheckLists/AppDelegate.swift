//
//  AppDelegate.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let dataModel = DataModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        //        let content = UNMutableNotificationContent()
        //        content.title = "test"
        //        content.body = "asdsadasdsadsdsadsd"
        //        content.sound = .default
        //        content.userInfo = ["itemID": 5, "listID": 4]
        //
        //        let request = UNNotificationRequest(identifier: "asd", content: content, trigger: nil)
        //        center.add(request, withCompletionHandler: nil)


        _ = dataModel.loadData()
        let controller = window?.rootViewController as? UINavigationController
        let allListsView = controller?.viewControllers.first as? AllListsViewController
        allListsView?.dataModel = dataModel

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveData()
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

        let controller = window?.rootViewController as? UINavigationController
        let allListsView = controller?.viewControllers.first as? AllListsViewController
        allListsView?.notificationTapped(for: itemID as! Int, inList: listID as! Int)

        completionHandler()
    }


    // MARK:- helper methods
    func saveData() {
        dataModel.saveData()
    }
}

