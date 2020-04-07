//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController {
    
    // MARK:- instance variables/properties
    let items = [CheckListItem(title: "Naruto", isChecked: false),
                 CheckListItem(title: "Black Widow", isChecked: true),
                 CheckListItem(title: "Bleach", isChecked: true),
                 CheckListItem(title: "Interstellar", isChecked: false),
                 CheckListItem(title: "Inception", isChecked: false),
                 CheckListItem(title: "Avengers", isChecked: true),
                 CheckListItem(title: "Spiderman", isChecked: true),
                 CheckListItem(title: "Zendaya ❤️", isChecked: true),
                 CheckListItem(title: "Captain America", isChecked: false),
                 CheckListItem(title: "Black Panther", isChecked: true),
                 CheckListItem(title: "Scarlet Witch", isChecked: true),
                 CheckListItem(title: "Thanos", isChecked: false),
                 CheckListItem(title: "Thor", isChecked: false),
                 CheckListItem(title: "Star Lord", isChecked: true),
                 CheckListItem(title: "Gamora", isChecked: true),
                 CheckListItem(title: "Groot", isChecked: false),
                 CheckListItem(title: "Rocket", isChecked: true),
                 CheckListItem(title: "Hulk", isChecked: true),]
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK:- table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath)
        let item = items[indexPath.row]
        
        //        cell.textLabel?.text = items[indexPath.item]
        let cellLabel = cell.viewWithTag(1000) as? UILabel
        cellLabel?.text = item.title
        configureCheckMark(for: cell, with: item)
        
        return cell
    }
    
    // something like android's onclick
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            item.toggleChecked()
            configureCheckMark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- member functions
    func configureCheckMark(for cell: UITableViewCell, with item: CheckListItem) {
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }
    
}

