//
//  CheckListItem.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

// codable protocol will allow the class to be encodable and decodable. need eg: when writing this object to a file.
// it basically makes this class serializable
// similar to NSCoder which xcode uses to write storyboards to file and ios uses to load app's story board
class Checklist: NSObject, Codable {

    var userID: String = ""
    var listID: String
    var pendingCount: Int {
        didSet {
            if pendingCount < 0 {
                pendingCount = 0
            }
        }
    }
    var totalItems: Int {
        didSet {
            if totalItems < 0 {
                totalItems = 0
            }
        }
    }
    var title: String
    var iconName: String

    internal init(title: String, listID: String = DataModel.nextChecklistUID(),
                  pendingCount: Int = 0, totalItems: Int = 0,
                  iconName: String = "No Icon") {
        self.listID = listID
        self.title = title
        self.iconName = iconName
        self.pendingCount = pendingCount
        self.totalItems = totalItems

        super.init()
    }
}

class ChecklistItem: NSObject, Codable {

    var userID: String = ""
    var itemID: String
    var listID: String
    var title: String
    var isChecked, shouldRemind, shouldRepeat: Bool
    var dueDate: Date


    internal init(title: String, listID: String, isChecked: Bool = false, shouldRemind: Bool = false, shouldRepeat: Bool = false, itemID: String = DataModel.nextChecklistItemID(), dueDate: Date = Date()) {
        self.title = title
        self.isChecked = isChecked
        self.shouldRemind = shouldRemind
        self.shouldRepeat = shouldRepeat
        self.dueDate = dueDate
        self.itemID = itemID
        self.listID = listID

        super.init()
    }
    
    func toggleChecked() {
        self.isChecked.toggle()
    }
}
