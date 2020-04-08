//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController {
    
    // MARK:- IBOutlets
    

    // MARK:- instance variables/properties
    var items = [CheckListItem(title: "Naruto", isChecked: false),
                 CheckListItem(title: "Black Widow", isChecked: true),
                 CheckListItem(title: "Zendaya ❤️", isChecked: true),
                 CheckListItem(title: "Rocket", isChecked: true),
                 CheckListItem(title: "Hulk", isChecked: true),]
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButtonItem.tintColor = .systemPurple
        navigationItem.leftBarButtonItem = editButtonItem
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row) // remove from list first
        // index path is already supplied by this method
        tableView.deleteRows(at: [indexPath], with: .automatic) // delete row
    }
    
    // MARK:- IBActions
    @IBAction func addItem() {
        let indexPath = IndexPath(row: items.count, section: 0) // create with the to be index of the new item (the current item size)
        let item = CheckListItem(title: "Chris Pratt", isChecked: true) // create the item
        items.append(item) // add the item to the list. Do this after you've created the indexpath for the new item
        tableView.insertRows(at: [indexPath], with: .automatic) // insert the row/item
    }
    
    // MARK:- member functions
    func configureCheckMark(for cell: UITableViewCell, with item: CheckListItem) {
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }
    
}

