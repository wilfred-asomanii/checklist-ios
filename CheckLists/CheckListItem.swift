//
//  CheckListItem.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class CheckListItem {
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
