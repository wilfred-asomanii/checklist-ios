//
//  ChecklistItemViewControllerData.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 29/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation
import UIKit

class ItemsData {
    static let remindCellID = "remindListItem"
    static let cellID = "listItem"
    var items = [ChecklistItem]()
}

class ItemsTableDataSource: NSObject, UITableViewDataSource {
    var itemData: ItemsData
    let dataController: DataController
    let checklist: Checklist
        
    init(itemData: ItemsData, in checklist: Checklist, dataController: DataController) {
        self.itemData = itemData
        self.dataController = dataController
        self.checklist = checklist
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemData.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = itemData.items[indexPath.row]
        guard item.shouldRemind else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemsData.cellID, for: indexPath) as! ItemCell
            cell.configure(with: item)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemsData.remindCellID, for: indexPath) as! RemindItemCell
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if case UITableViewCell.EditingStyle.delete = editingStyle {
            let deletedItem = self.itemData.items.remove(at: indexPath.row)
            dataController.removeListItem(deletedItem, in: checklist)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func removeItem(at path: IndexPath) {
        
    }
    
}

class ItemsTableDelegate: NSObject, UITableViewDelegate {
    
    var itemData: ItemsData
    let dataController: DataController
    let checklist: Checklist
    
    var itemRemoved: ((IndexPath) -> Void)?
    var editTapped: ((IndexPath) -> Void)?
    
    init(itemData: ItemsData, in checklist: Checklist, dataController: DataController) {
        self.itemData = itemData
        self.dataController = dataController
        self.checklist = checklist
        super.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            let item = itemData.items[indexPath.row]
            if !item.isChecked && item.shouldRemind {
                // task is completed but there's still a notification for it so remove
                item.shouldRemind = false
                item.shouldRepeat = false
                dataController.toggleNotification(for: item)
            }
            item.toggleChecked()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            dataController.setListItem(item) { [weak self] state in
                guard let self = self, case DataState.success(_) = state else { return }
                self.checklist.pendingCount += item.isChecked ? -1 : 1
                self.dataController.setList(self.checklist)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {action, view, handler in
            self.swipeActionTapped(action: action, view: view, handler: handler, indexPath: indexPath)
        })
        editAction.backgroundColor = .systemPurple
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {action, view, handler in
            self.swipeActionTapped(action: action, view: view, handler: handler, indexPath: indexPath)
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemData.items[indexPath.row].shouldRemind ? 80 : 70
    }
    
    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""
        
        if title == "Edit" {
            editTapped?(indexPath)
        } else if title == "Delete" {
            removeItem(at: indexPath)
        }
        handler(true)
    }
    
    func removeItem(at path: IndexPath) {
        let deletedItem = self.itemData.items.remove(at: path.row)
        dataController.removeListItem(deletedItem, in: checklist)
        itemRemoved?(path)
    }
}
