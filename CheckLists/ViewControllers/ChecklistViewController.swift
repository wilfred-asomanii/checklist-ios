//
//  ViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 07/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

typealias DidAction = (_ isDelete:Bool,Checklist) -> Void
class ChecklistViewController: UITableViewController {
    
    // MARK:- instance variables/properties
    var didAction: DidAction?
    var checklist: Checklist!
    var items = [ChecklistItem]()
    var item: ChecklistItem? // this will be passed if a notification of said item is tapped
    var dataController: DataController!
    var hud: JGProgressHUD?

    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        
        tableView.tableFooterView = UIView()

        guard let checklist = checklist else {
            navigationController?.popViewController(animated: true)
            return
        }
        title = checklist.title
        loadData()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItemSegue"
            || segue.identifier == "EditItemSegue"  {
            initItemViewSegue(segue, sender)
        }
    }
    
    // MARK:- member functions
    
    func initItemViewSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let controller = navController.topViewController as! ItemViewController
        controller.didFinishSaving = { [weak self] item, _ in
            guard let self = self else { return }
            guard let index = self.items.firstIndex(of: item) else {
                // add
                let path = IndexPath(row: self.items.count, section: 0)
                self.items.append(item)
                self.tableView.insertRows(at: [path], with: .bottom)
                return
            }
            // update
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        controller.checklist = checklist
        controller.dataController = dataController
        // in this case, the triger of the segue is a cell
        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            controller.itemToEdit = items[indexPath.row]
        }
    }
    
    func loadData() {
        showIndicator(for: .loading)
        dataController.getListItems(in: checklist.listID) { [weak self] state in
            self?.showIndicator(for: state)
            if case DataState.success(let items as [ChecklistItem]) = state {
                self?.items = items
                self?.tableView.reloadSections([0], with: .automatic)
                
                // briefly highlight listItem if one was passed
                guard let self = self,
                    let item = self.item,
                    let index = items.firstIndex(where: { $0.itemID == item.itemID })
                    else { return }
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.highlightRow(at: indexPath)
                self.item = nil
            }
        }
    }
    
    fileprivate func showIndicator(for state: DataState) {
        hud?.dismiss()
        hud = HudView.showIndicator(for: state, in: view)
    }
    
    func removeItem(at path: IndexPath) {
        let deletedItem = self.items.remove(at: path.row)
        dataController.removeListItem(deletedItem, in: checklist)
        tableView.deleteRows(at: [path], with: .left)
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

// MARK:- tableview data source
extension ChecklistViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        guard item.shouldRemind else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listItem", for: indexPath) as! ItemCell
            cell.configure(with: item)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "remindListItem", for: indexPath) as! RemindItemCell
        cell.configure(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
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
    
}

// MARK:- preview stuff

extension ChecklistViewController {
    override var previewActionItems: [UIPreviewActionItem] {
        let delAction = UIPreviewAction(title: "Delete", style: .destructive) { _, _ in
            self.didAction?(true, self.checklist)
        }
        let editAction = UIPreviewAction(title: "Edit", style: .default) { _, _ in
            self.didAction?(false, self.checklist)
        }
        return [editAction, delAction]
    }
}

// MARK:- factories
extension ChecklistViewController {
    class func checklistViewController(for checklist: Checklist, storyboard: UIStoryboard, dataController: DataController) -> ChecklistViewController? {
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CheckListViewController") as? ChecklistViewController else {
            return nil
        }
        vc.checklist = checklist
        vc.dataController = dataController
        return vc
    }
}
