//
//  ChecklistItem.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 25/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, Codable {
    
    var userID: String = ""
    var itemID: String
    var listID: String
    var title: String
    var isChecked, shouldRemind, shouldRepeat: Bool
    var dueDate: Date
    
    
    internal init(title: String, listID: String, isChecked: Bool = false,
                  shouldRemind: Bool = false, shouldRepeat: Bool = false,
                  itemID: String = DataController.nextChecklistItemID(),
                  dueDate: Date = Date()) {
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
