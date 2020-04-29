//
//  IconsDataSource.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 29/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit

class IconsDataSource: NSObject, UITableViewDataSource {
    let didPick: DidPickIcon?
    let icons = [ "No Icon", "Appointments", "Birthdays", "Chores",
    "Drinks", "Folder", "Groceries", "Inbox", "Photos", "Trips" ]
    
    init(didPick: DidPickIcon? = nil) {
        self.didPick = didPick
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath)
        
        cell.textLabel?.text = icons[indexPath.row]
        cell.imageView?.image = UIImage(named: icons[indexPath.row])
        cell.imageView?.tintColor = .systemPurple
        
        return cell
    }
    
}

extension IconsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didPick?(icons[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
