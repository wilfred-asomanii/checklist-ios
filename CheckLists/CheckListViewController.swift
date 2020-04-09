//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, ItemViewControllerDelegate {
    

    // MARK:- instance variables/properties
    var items = [CheckListItem]()
    var checklist: CheckListItem?
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems?.append(editButtonItem)
        guard let checklist = checklist else {
            navigationController?.popViewController(animated: true)
            return
        }
        title = checklist.title
        loadCheckLists()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // this method is called right before a seque navigation.
        // use it to pass data to the next screen
        // the sender parameter here is the basically what trigured the segue
        if segue.identifier == "AddItemSegue" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! ItemViewController
            controller.itemViewDelegate = self
        } else if segue.identifier == "EditItemSegue" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! ItemViewController
            controller.itemViewDelegate = self
            // in this case, the triger of the segue is a cell
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = items[indexPath.row]
            }
        }
    }
    
    // MARK:- table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath)
        let item = items[indexPath.row]
        

        configureCheckMarkNText(for: cell, with: item)
        
        return cell
    }
    
    // something like android's onclick
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            item.toggleChecked()
            configureCheckMarkNText(for: cell, with: item)
            saveChecklistItems()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row) // remove from list first
        // index path is already supplied by this method
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveChecklistItems()
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {action, view, handler in
            self.swipeActionTapped(action: action, view: view, handler: handler, indexPath: indexPath)
        })
        editAction.backgroundColor = .systemPurple
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {action, view, handler in
            self.swipeActionTapped(action: action, view: view, handler: handler, indexPath: indexPath)
        })

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // MARK:- add item view controller delegates

    func itemViewController(_ controller: ItemViewController, editedItem item: CheckListItem) {

        if let index = items.firstIndex(of: item) {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                configureCheckMarkNText(for: cell, with: item)
            }
        }
        saveChecklistItems()
    }

    func itemViewController(_ controller: ItemViewController, addedItem item: CheckListItem) {
        let indexPath = IndexPath(row: items.count, section: 0)
        items.append(item)
        tableView.insertRows(at: [indexPath], with: .automatic)

        saveChecklistItems()
    }
    
    // MARK:- member functions
    func configureCheckMarkNText(for cell: UITableViewCell, with item: CheckListItem) {
        //        cell.textLabel?.text = items[indexPath.item]
        let cellLabel = cell.viewWithTag(1000) as? UILabel
        cellLabel?.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }

    func loadCheckLists() {
        if let data = try? Data(contentsOf: dataFilePath()) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([CheckListItem].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""

        if title == "Edit" {
            performSegue(withIdentifier: "EditItemSegue", sender: tableView.cellForRow(at: indexPath))
        } else if title == "Delete" {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveChecklistItems()
        }
        handler(true)
    }

    func saveChecklistItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            // the error variable is implicitly made available by swit in a do-try-catch block
            print(error.localizedDescription)
        }
        // the below style, you don't need to catch the error. swift simply continues executing like nothing happened.
        // use this when you don't need to necessarily handle error
        // let data = try? encoder.encode(items)
        // try? data?.write(to: dataFilePath())
    }

//    func documentsDirectory() -> URL {
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//
//        return path[0]
//    }
//
//    func dataFilePath() -> URL {
//        return documentsDirectory().appendingPathComponent("CheckList.plist")
//    }
}

