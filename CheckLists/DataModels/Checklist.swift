//
//  CheckListItem.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

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

    internal init(title: String, listID: String = DataController.nextChecklistUID(),
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
