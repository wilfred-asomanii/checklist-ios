//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemViewControllerDelegate {
    

    // MARK:- instance variables/properties
    var checklist: Checklist!
    var item: ChecklistItem? // this will be passed if a notification of said item is tapped
    var dataModel: DataModel!
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems?.append(editButtonItem)
        guard let checklist = checklist else {
            navigationController?.popViewController(animated: true)
            return
        }
        title = checklist.title
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // briefly highlight listItem if one was passed
        guard let item = item else {
            return
        }
        if let index = checklist.items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
    
    // MARK:- table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        let item = checklist.items[indexPath.row]
        if item.shouldRemind {
            cell = tableView.dequeueReusableCell(withIdentifier: "remindListItem", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "listItem", for: indexPath)
        }

        configureCheckMarkNText(for: cell, with: item)
        
        return cell
    }
    
    // something like android's onclick
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist.items[indexPath.row]
            if !item.isChecked && item.shouldRemind {
                // task is completed but there's still a notification for it so remove
                item.shouldRemind = false
                item.shouldRepeat = false
                dataModel.toggleNotification(for: item, inList: checklist.listID)
            }
            item.toggleChecked()
            configureCheckMarkNText(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: indexPath.row) // remove from list first
        // index path is already supplied by this method
        tableView.deleteRows(at: [indexPath], with: .automatic)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return checklist.items[indexPath.row].shouldRemind ? 80 : 70
    }

    // MARK:- add item view controller delegates

    func itemViewController(_ controller: ItemViewController, didFinishEditing item: ChecklistItem) {
        dataModel.toggleNotification(for: item, inList: checklist.listID)
        if let index = checklist.items.firstIndex(of: item) {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                configureCheckMarkNText(for: cell, with: item)
            }
        }
        tableView.reloadSections([0], with: .automatic)
    }

    func itemViewController(_ controller: ItemViewController, didFinishAdding item: ChecklistItem) {

        dataModel.toggleNotification(for: item, inList: checklist.listID)
        let indexPath = IndexPath(row: checklist.items.count, section: 0)
        checklist.items.append(item)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK:- member functions
    func configureCheckMarkNText(for cell: UITableViewCell, with item: ChecklistItem) {
        cell.textLabel?.text = item.title
        cell.textLabel?.numberOfLines = 2

        if item.shouldRemind {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
            cell.detailTextLabel?.text = "Due \(formatter.string(from: item.dueDate))"
            cell.detailTextLabel?.textColor = item.dueDate < Date() ? .systemRed : .systemPurple
        }

        cell.accessoryType = item.isChecked ? .checkmark : .none
    }

    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""

        if title == "Edit" {
            performSegue(withIdentifier: "EditItemSegue", sender: tableView.cellForRow(at: indexPath))
        } else if title == "Delete" {
            let deletedItem = checklist.items.remove(at: indexPath.row)
            if deletedItem.shouldRemind {
                deletedItem.shouldRemind = false
                deletedItem.shouldRepeat = false
                dataModel.toggleNotification(for: deletedItem, inList: checklist.listID)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        handler(true)
    }
}

