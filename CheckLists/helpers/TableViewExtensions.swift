//
//  TableViewExtensions.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 25/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func highlightRow(at path: IndexPath) {
        selectRow(at: path, animated: true, scrollPosition: .middle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            [weak self] in self?.deselectRow(at: path, animated: true)
        }
    }
}
