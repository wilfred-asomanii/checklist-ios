//
//  DataModel.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 10/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UserNotifications

class DataModel {
    var checklists = [Checklist]()
    var prevSelectedIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            //            UserDefaults.standard.synchronize() // this forces userDefaults to persist to disk immediately its updated
        }
    }

    init() {
        _ = loadData()
        registerDefaults()
        handleFirstTime()
    }

    func registerDefaults() {
        let defaults = ["ChecklistIndex": -1, "FirstTime": true] as [String: Any]
        UserDefaults.standard.register(defaults: defaults)
    }

    func saveData() {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(checklists)
        try? data?.write(to: dataFilePath())
    }

    func loadData() -> [Checklist] {
        if let data = try? Data(contentsOf: dataFilePath()) {
            let decoder = PropertyListDecoder()
            checklists = (try? decoder.decode([Checklist].self, from: data)) ?? []
        }

        return checklists
    }

    func sortChecklists() {
        checklists.sort() { list1, list2 in
            // compare 2 strings in a case agnostic way
            // also compare based on locale (sorting english can be diff from sorting german
            return list1.title.localizedCompare(list2.title) == .orderedAscending
        }
    }

    func handleFirstTime() {
        if UserDefaults.standard.bool(forKey: "FirstTime") {
            checklists.append(Checklist(title: "To Do", iconName: "Appointments"))
            prevSelectedIndex = 0
            UserDefaults.standard.set(false, forKey: "FirstTime")
            UserDefaults.standard.synchronize()
        }
    }

    func toggleNotification(for item: ChecklistItem) {
        // remove pending notif for this item
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
            [weak self] granted, _ in
            if granted { self?.finaliseNotifcationToggle(item, center) }
        }
    }

    func finaliseNotifcationToggle(_ item: ChecklistItem, _ center: UNUserNotificationCenter) {
        unscheduleNotification(for: item, notificationCenter: center)
        if item.shouldRemind && item.dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Remember!"
            content.body = item.title
            content.sound = .default

            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(item.itemID)", content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }

    func unscheduleNotification(for item: ChecklistItem, notificationCenter: UNUserNotificationCenter?) {
        var center = notificationCenter
        if center == nil {
            center = UNUserNotificationCenter.current()
        }
        center?.removePendingNotificationRequests(withIdentifiers: ["\(item.itemID)"])
    }

    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return path[0]
    }

    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("CheckList.plist")
    }

    // MARK:- class funcs
    // these functions can be called without refference to an instance of this class as opposed to instance methods
    // eg: DataModel.classFunc() vs DataModel().instanceFunc()
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "ChecklistItemID")
        let nextID = currentID + 1
        userDefaults.set(nextID, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return nextID
    }

    class func nextChecklistID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "ChecklistID")
        let nextID = currentID + 1
        userDefaults.set(nextID, forKey: "ChecklistID")
        userDefaults.synchronize()
        return nextID
    }
}
