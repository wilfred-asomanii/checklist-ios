//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChecklistViewController: UITableViewController {
    
    
    // MARK:- instance variables/properties
    var checklist: Checklist!
    var items = [ChecklistItem]()
    var item: ChecklistItem? // this will be passed if a notification of said item is tapped
    var dataModel: DataModel!
    var hud: HudView?
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        guard let checklist = checklist else {
            navigationController?.popViewController(animated: true)
            return
        }
        title = checklist.title
        loadData()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItemSegue" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! ItemViewController
            controller.delegate = self
            controller.dataModel = dataModel
            controller.checklist = checklist
        } else if segue.identifier == "EditItemSegue" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! ItemViewController
            controller.delegate = self
            controller.checklist = checklist
            controller.dataModel = dataModel
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
        var cell: UITableViewCell!
        
        let item = items[indexPath.row]
        if item.shouldRemind {
            cell = tableView.dequeueReusableCell(withIdentifier: "remindListItem", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "listItem", for: indexPath)
        }
        
        configCell(for: cell, with: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            if !item.isChecked && item.shouldRemind {
                // task is completed but there's still a notification for it so remove
                item.shouldRemind = false
                item.shouldRepeat = false
                dataModel.toggleNotification(for: item)
            }
            item.toggleChecked()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            dataModel.setListItem(item) { [weak self] state in
                guard let self = self, case DataState.success(_) = state else { return }
                self.checklist.pendingCount += item.isChecked ? -1 : 1
                self.dataModel.setList(self.checklist)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if case UITableViewCell.EditingStyle.delete = editingStyle {
            removeItem(at: indexPath)
        }
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
        
        return items[indexPath.row].shouldRemind ? 80 : 70
    }
    
    // MARK:- member functions
    
    func loadData() {
        showIndicator(for: .loading)
        dataModel.getListItems(in: checklist.listID) { [weak self] state in
            self?.showIndicator(for: state)
            if case DataState.success(let items as [ChecklistItem]) = state {
                self?.items = items
                self?.tableView.reloadSections([0], with: .automatic)
                
                // briefly highlight listItem if one was passed
                guard let self = self,
                    let item = self.item,
                    let index = items.firstIndex(of: item) else { return }
                
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.item = nil
            }
        }
    }
    
    fileprivate func showIndicator(for state: DataState) {
        hud?.removeFromSuperview()
        hud = HudView.hud(inView: navigationController!.view,
                              animated: true, state: state)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.hud?.hide()
        }
    }
    
    func removeItem(at path: IndexPath) {
        showIndicator(for: .loading)
        let deletedItem = self.items.remove(at: path.row)
        dataModel.removeListItem(deletedItem) {
            [weak self] state in
            self?.showIndicator(for: state)
            guard let self = self,
                case DataState.success(_) = state else { return }
            self.tableView.deleteRows(at: [path], with: .left)
            self.checklist.pendingCount += !deletedItem.isChecked ? -1 : 0
            self.checklist.totalItems -= 1
            self.dataModel.setList(self.checklist)
            guard deletedItem.shouldRemind else { return }
            deletedItem.shouldRemind = false
            deletedItem.shouldRepeat = false
            self.dataModel.toggleNotification(for: deletedItem)
        }
    }
    
    func configCell(for cell: UITableViewCell, with item: ChecklistItem) {
        cell.textLabel?.text = item.title
        cell.textLabel?.numberOfLines = 2
        
        cell.accessoryType = item.isChecked ? .checkmark : .none
        
        guard item.shouldRemind else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        cell.detailTextLabel?.text = "Due \(formatter.string(from: item.dueDate))"
        cell.detailTextLabel?.textColor = item.dueDate < Date() ? .systemRed : .systemPurple
    }
    
    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""
        
        if title == "Edit" {
            performSegue(withIdentifier: "EditItemSegue", sender: tableView.cellForRow(at: indexPath))
        } else if title == "Delete" {
            removeItem(at: indexPath)
        }
        handler(true)
    }
}

// MARK:- ItemViewControllerDelegate
extension ChecklistViewController: ItemViewControllerDelegate {
    func itemViewController(_ controller: ItemViewController, didFinishEditing item: ChecklistItem) {
        guard let index = items.firstIndex(of: item) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func itemViewController(_ controller: ItemViewController, didFinishAdding item: ChecklistItem) {
        let path = IndexPath(row: items.count, section: 0)
        items.append(item)
        tableView.insertRows(at: [path], with: .bottom)
    }
}
