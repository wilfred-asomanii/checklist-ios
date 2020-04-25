//
//  DataModel.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 10/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

enum DataState {
    case loading
    case error(Error?)
    case success(Any?)
}

typealias DataCompletion = (DataState) -> Void

class DataModel {
    private var store: Firestore {
        Firestore.firestore()
    }
    private var userID: String {
        FirebaseAuth.Auth.auth().currentUser!.uid
    }
    
    init() {
        registerDefaults()
    }
    
    func registerDefaults() {
        let defaults = ["ChecklistIndex": -1, "FirstTime": true] as [String: Any]
        UserDefaults.standard.register(defaults: defaults)
    }
    
    func getLists(then completion: DataCompletion? = nil) {
        store.collection("checklists")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { data, error in
                if let error = error { completion?(.error(error)); return }
                guard let data = data else {
                    completion?(.error(nil))
                    return
                }
                let lists: [Checklist?] = data.documents.map { doc in
                    let res = Result {
                        try doc.data(as: Checklist.self)
                    }
                    switch res {
                    case .success(let list):
                        return list
                    default:
                        return nil
                    }
                }
                completion?(.success(lists))
        }
    }
    
    func listenLists(then completion: DataCompletion? = nil) -> ListenerRegistration {
        return store.collection("checklists")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { data, error in
                if let error = error { completion?(.error(error)); return }
                guard let data = data else { return }
                let lists: [Checklist?] = data.documents.map { doc in
                    let res = Result {
                        try doc.data(as: Checklist.self)
                    }
                    switch res {
                    case .success(let list):
                        return list
                    default:
                        return nil
                    }
                }
                completion?(.success(lists))
        }
    }
    
    func getList(_ listId: String, then completion: DataCompletion? = nil) {
        store.collection("checklists").document(listId)
            .getDocument { doc, error in
                if let error = error { completion?(.error(error)); return }
                guard let doc = doc else {
                    completion?(.error(nil));
                    return
                }
                let res = Result {
                    try doc.data(as: Checklist.self)
                }
                switch res {
                case .success(let list):
                    completion?(.success(list))
                default:
                    completion?(.error(nil))
                }
        }
    }
    
    func setList(_ list: Checklist, then completion: DataCompletion? = nil) {
        list.userID = userID
        do {
            let _ = try store.collection("checklists").document(list.listID).setData(from: list)
            completion?(.success(list))
        } catch {
            completion?(.error(error))
        }
    }
    
    func removeList(_ list: Checklist, then completion: DataCompletion? = nil) {
        store.collection("checklists").document("\(list.listID)").delete { [weak self] error in
            if let error = error {
                completion?(.error(error))
                return
            }
            self?.bulkDeleteItems(for: list.listID, where: ["field": "shouldRemind", "value": true])
            completion?(.success(nil))
        }
    }
    
    func bulkDeleteItems(for listID: String, where term: [String:Any]?, then completion: DataCompletion? = nil) {
        var query = store.collection("checklist-items")
            .whereField("userID", isEqualTo: userID)
            .whereField("listID", isEqualTo: listID)
        
        if let term = term {
            query = query
                .whereField(term["field"] as! String, isEqualTo: term["value"]!)
        }
        
        query.getDocuments {
                data, error in
                if let error = error { completion?(.error(error)); return }
                data?.documents.forEach { [weak self] doc in
                    guard let item = try? doc.data(as: ChecklistItem.self) else { return }
                    
                    self?.store.collection("checklist-items").document(item.itemID).delete()
                    item.shouldRemind = false
                    item.shouldRepeat = false
                    self?.toggleNotification(for: item)
                }
        }
    }
    
    func getListItems(in listID: String, where term: [String:Any]? = nil, then completion: DataCompletion? = nil) {
        var query = store.collection("checklist-items")
            .whereField("userID", isEqualTo: userID)
            .whereField("listID", isEqualTo: listID)
        
        if let term = term {
            query = query
                .whereField(term["field"] as! String, isEqualTo: term["value"]!)
        }
        
        query.getDocuments { data, error in
                if let error = error { completion?(.error(error)); return }
                let items: [ChecklistItem?] = data!.documents.map { doc in
                    let res = Result {
                        try doc.data(as: ChecklistItem.self)
                    }
                    switch res {
                    case .success(let item):
                        return item
                    default:
                        return nil
                    }
                }
                let res = DataState.success(items.filter { i in i != nil } as! [ChecklistItem])
                completion?(res)
        }
    }
    
    func listenListItems(in listID: String, then completion: DataCompletion? = nil) -> ListenerRegistration {
        let query = store.collection("checklist-items")
            .whereField("userID", isEqualTo: userID)
            .whereField("listID", isEqualTo: listID)
        return query.addSnapshotListener { data, error in
            if let error = error { completion?(.error(error)); return }
            guard let data = data else { return }
            let items: [ChecklistItem?] = data.documents.map { doc in
                let res = Result {
                    try doc.data(as: ChecklistItem.self)
                }
                switch res {
                case .success(let list):
                    return list
                default:
                    return nil
                }
            }
            completion?(.success(items))
        }
    }
    
    func getListItem(_ itemId: String, then completion: DataCompletion? = nil) {
        store.collection("checklist-items").document(itemId)
            .getDocument { doc, error in
                if let error = error { completion?(.error(error)); return }
                guard let doc = doc else {
                    completion?(.error(nil));
                    return
                }
                let res = Result {
                    try doc.data(as: ChecklistItem.self)
                }
                switch res {
                case .success(let list):
                    completion?(.success(list))
                default:
                    completion?(.error(nil))
                }
        }
    }
    
    func setListItem(_ item: ChecklistItem, then completion: DataCompletion? = nil) {
        item.userID = userID
        do {
            let _ = try store.collection("checklist-items").document("\(item.itemID)").setData(from: item)
            completion?(.success(item))
        } catch {
            completion?(.error(error))
        }
    }
    
    func removeListItem(_ item: ChecklistItem, then completion: DataCompletion? = nil) {
        store.collection("checklist-items").document("\(item.itemID)").delete { error in
            if let error = error {
                completion?(.error(error))
                return
            }
            completion?(.success(nil))
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
    
    private func finaliseNotifcationToggle(_ item: ChecklistItem, _ center: UNUserNotificationCenter) {
        unscheduleNotification(for: item, notificationCenter: center)
        if item.shouldRemind && !item.isChecked && item.dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Remember!"
            content.body = item.title
            content.sound = .default
            let userInfo = ["listID": item.listID, "itemID": item.itemID]
            content.userInfo = userInfo
            
            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: item.shouldRepeat)
            let request = UNNotificationRequest(identifier: item.itemID, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }
    
    private func unscheduleNotification(for item: ChecklistItem, notificationCenter: UNUserNotificationCenter?) {
        var center = notificationCenter
        if center == nil {
            center = UNUserNotificationCenter.current()
        }
        center?.removePendingNotificationRequests(withIdentifiers: [item.itemID])
    }
    
    // MARK:- class funcs
    // these functions can be called without refference to an instance of this class as opposed to instance methods
    // eg: DataModel.classFunc() vs DataModel().instanceFunc()
    class func nextChecklistItemID() -> String {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "ChecklistItemID")
        let nextID = currentID + 1
        userDefaults.set(nextID, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return FirebaseAuth.Auth.auth().currentUser!.uid + "\(nextID)"
    }
    
    class func nextChecklistUID() -> String {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "ChecklistID")
        let nextID = currentID + 1
        userDefaults.set(nextID, forKey: "ChecklistID")
        userDefaults.synchronize()
        return FirebaseAuth.Auth.auth().currentUser!.uid + "\(nextID)"
    }
}
