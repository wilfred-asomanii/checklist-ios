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

    var listID: Int
    var title: String
    var iconName: String
    var items: [ChecklistItem]

    internal init(title: String, listID: Int = DataModel.nextChecklistID(), iconName: String = "No Icon", listItems: [ChecklistItem] = []) {
        self.listID = listID
        self.title = title
        self.items = listItems
        self.iconName = iconName

        super.init()
    }
}

class ChecklistItem: NSObject, Codable {

    var itemID: Int
    var title: String
    var isChecked, shouldRemind: Bool
    var dueDate: Date


    internal init(title: String, isChecked: Bool = false, shouldRemind: Bool = false, itemID: Int = DataModel.nextChecklistItemID(), dueDate: Date = Date()) {
        self.title = title
        self.isChecked = isChecked
        self.shouldRemind = shouldRemind
        self.dueDate = dueDate
        self.itemID = itemID

        super.init()
    }
    
    func toggleChecked() {
        self.isChecked.toggle()
    }
}
