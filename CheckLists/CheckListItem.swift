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
class CheckListItem: NSObject, Codable {

    var title: String
    var isChecked: Bool
    
    internal init(title: String, isChecked: Bool) {
        self.title = title
        self.isChecked = isChecked
    }
    
    func toggleChecked() {
        self.isChecked.toggle()
    }
}
