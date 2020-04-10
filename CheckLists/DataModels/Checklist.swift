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
    var title: String
    var items: [ChecklistItem]

    internal init(title: String, listItems: [ChecklistItem] = []) {
        self.title = title
        self.items = listItems

        super.init()
    }
}

class ChecklistItem: NSObject, Codable {

    var title: String
    var isChecked: Bool

    internal init(title: String, isChecked: Bool = false) {
        self.title = title
        self.isChecked = isChecked

        super.init()
    }
    
    func toggleChecked() {
        self.isChecked.toggle()
    }
}