//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, AddItemViewControllerDelegate {
    
    // MARK:- IBOutlets
    

    // MARK:- instance variables/properties
    var items = [CheckListItem(title: "Naruto", isChecked: false),
                 CheckListItem(title: "Black Widow", isChecked: false),
                 CheckListItem(title: "Zendaya ❤️", isChecked: true),
                 CheckListItem(title: "Rocket", isChecked: false),
                 CheckListItem(title: "Hulk", isChecked: false),]
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButtonItem.tintColor = .systemPurple
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // this method is called right before a seque navigation.
        // use it to pass data to the next screen
        if segue.identifier == "AddItemSegue" {
            let controller = segue.destination as! AddItemTableViewController
            controller.addItemDelegate = self
        }
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

    // MARK:- add item view controller delegates

    func addItemViewControllerDidCancel(_ controller: AddItemTableViewController) {
        navigationController?.popViewController(animated: true)
    }

    func addItemViewController(_ controller: AddItemTableViewController, addedItem item: CheckListItem) {
        navigationController?.popViewController(animated: true)
        let indexPath = IndexPath(row: items.count, section: 0)
        items.append(item)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK:- IBActions
    
    // MARK:- member functions
    func configureCheckMark(for cell: UITableViewCell, with item: CheckListItem) {
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }
    
}

