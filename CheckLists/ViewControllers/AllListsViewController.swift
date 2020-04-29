//
//  AllListsViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseFirestore
import JGProgressHUD

class AllListsViewController: UITableViewController,
UISearchResultsUpdating {
    
    // MARK:- variables
    let cellIdentier = "list-cell"
    var searchController: UISearchController?
    var isSearching: Bool {
        searchController != nil
            && searchController!.searchBar.text != nil
            && searchController!.searchBar.text!.count > 0
    }
    var dataController: DataController!
    var checklists = [Checklist]()
    var openRow: Int?
    var hud: JGProgressHUD?
    
    let searchResController = SearchViewController()
    var previewController: ChecklistViewController?
    var previewRow: Int?
    
    // MARK:- View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = editButtonItem
        
        // get rid of empty cells in plain-style table
        tableView.tableFooterView = UIView()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        guard let i = openRow else { return }
        tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddItemSegue" {
            initItemViewSegue(segue, sender)
        } else if segue.identifier == "showChecklistSegue" {
            initChecklistViewSegue(segue, sender)
        } else if segue.identifier == "listDetailSegue" {
            initListDetailSegue(segue, sender)
        }
    }
    
    // search delegate
    func updateSearchResults(for searchController: UISearchController) {
        refreshSearch()
    }
    
    // MARK:- member functions
    
    func loadData() {
        showIndicator(for: .loading)
        dataController.getLists { [weak self] state in
            self?.hud?.indicatorView = JGProgressHUDSuccessIndicatorView()
            self?.hud?.dismiss(afterDelay: 0.7, animated: true)
            guard case DataState.success(let lists as [Checklist]) = state  else { return }
            self?.checklists = lists
            self?.initSearch()
            guard lists.count > 0 else { return }
            self?.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    // MARK: search stuff
    func initSearch() {
        searchResController.cellTapped = { list in
            guard let index = self.checklists.firstIndex(of: list) else { return }
            let path = IndexPath(row: index, section: 0)
            self.performSegue(withIdentifier: "showChecklistSegue", sender: self.checklists[path.row])
        }
        searchResController.cellActionTapped = swipeActionTapped
        searchResController.lists = checklists
        searchController = UISearchController(searchResultsController: searchResController)
        searchController!.searchResultsUpdater = self
        searchController!.obscuresBackgroundDuringPresentation = true
        searchController!.searchBar.placeholder = "Search checklists"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func refreshSearch() {
        guard isSearching else { return }
        searchResController.lists = checklists.filter { $0.title.lowercased().contains(searchController!.searchBar.text!.lowercased()) }
        searchResController.term = searchController!.searchBar.text!
    }
    
    func initChecklistViewSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        let checklist: Checklist
        let controller = segue.destination as! ChecklistViewController
        if let cell = sender as? UITableViewCell,
            let path = tableView.indexPath(for: cell) {
            checklist = checklists[path.row]
            controller.didAction = {
                [weak self] isDelete, list in
                guard let self = self else { return }
                guard let row = self.checklists.firstIndex(of: list) else { return }
                if isDelete {
                    self.removeList(at: IndexPath(row: row, section: 0))
                } else {
                    self.performSegue(withIdentifier: "listDetailSegue", sender: IndexPath(row: row, section: 0))
                }
            }
            
        } else if let list = sender as? Checklist {
            checklist = list
            
        } else if let data = sender as? [String: Any],
            let list = data["checklist"] as? Checklist,
            let item = data["listItem"] as? ChecklistItem {
            
            checklist = list
            controller.item = item
            
        } else {
            return
        }
        controller.dataController = dataController
        controller.checklist = checklist
        openRow = checklists.firstIndex(of: checklist)
    }
    
    func initItemViewSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
            let controller = navController.topViewController as? ItemViewController,
            let checklist = sender as? Checklist else { return }
        controller.dataController = dataController
        controller.checklist = checklist
        controller.didFinishSaving = { [weak self] _, list in
            guard let self = self else { return }
            self.checklists[self.openRow!] = list
            self.tableView.reloadRows(at: [IndexPath(row: self.openRow!, section: 0)], with: .automatic)
        }
    }
    
    func initListDetailSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        let navController = segue.destination as! UINavigationController
        guard let controller = navController.topViewController as? ListDetailViewController else { return }
        controller.dataController = dataController
        controller.didFinishSaving = { [weak self] l in
            guard let self = self else { return }
            guard let index = self.checklists.firstIndex(of: l) else {
                // add
                let path = IndexPath(row: self.checklists.count, section: 0)
                self.checklists.append(l)
                self.tableView.insertRows(at: [path], with: .bottom)
                return
            }
            // update
            let path = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [path], with: .automatic)
            self.refreshSearch()
        }
        guard let path = sender as? IndexPath else { return }
        controller.checklist = checklists[path.row]
    }
    
    fileprivate func showIndicator(for state: DataState) {
        hud?.dismiss()
        hud = HudView.showIndicator(for: state, in: view)
    }
    
    func removeList(at path: IndexPath) {
        let list = checklists.remove(at: path.row)
        dataController.removeList(list)
        self.tableView.deleteRows(at: [path], with: .left)
    }
    
    func swipeActionTapped(_ action: UIContextualAction, _ view: UIView, _ list: Checklist, _ handler: (Bool) -> Void) {
        let title = action.title ?? ""
        
        guard let row = checklists.firstIndex(of: list) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        if title == "Edit" {
            performSegue(withIdentifier: "listDetailSegue", sender: indexPath)
        } else if title == "Delete" {
            removeList(at: indexPath)
        }
        handler(true)
    }
    
    func notificationTapped(for itemID: String, in listID: String) {
        dataController.getListAndItem(itemID, in: listID) { [weak self] state in
            guard case DataState.success(let d) = state,
                let data = d as? [String:Any],
                let item = data["item"] as? ChecklistItem,
                let list = data["list"] as? Checklist
                else { return }
            let topView = self?.navigationController?.topViewController as? AllListsViewController
            if topView == nil {
                // this controller is not the topmost view so pop
                self?.navigationController?.popToRootViewController(animated: true)
            }
            
            if self?.presentedViewController != nil {
                self?.dismiss(animated: true, completion: nil) // in case there's a modal over this controller
            }
            self?.performSegue(withIdentifier: "showChecklistSegue", sender: ["checklist": list, "listItem": item])
        }
    }
}

// MARK:- tableview data source
extension AllListsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return checklists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let list = checklists[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier) as! ListCell
        
        cell.configure(with: list)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return checklists.count == 0 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case UITableViewCell.EditingStyle.delete = editingStyle else { return }
        removeList(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard checklists.count > 0 else { return nil }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            action, view, handler in
            self.swipeActionTapped(action, view, self.checklists[indexPath.row], handler)
        }
        editAction.backgroundColor = .systemPurple
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            action, view, handler in
            self.swipeActionTapped(action, view, self.checklists[indexPath.row], handler)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

// MARK: previewing stuff
extension AllListsViewController {
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let list = checklists[indexPath.row]
        let provider: UIContextMenuContentPreviewProvider?
        if list.totalItems > 0 {
            provider = {
                self.previewController = self.previewProvider(for: indexPath)
                self.previewRow = indexPath.row
                return self.previewController
            }
        } else {
            provider = nil
        }
        let config = UIContextMenuConfiguration(
            identifier: "\(indexPath.row)" as NSString,
            previewProvider: provider,
            actionProvider: { _ in
                return UIMenu(title: "",
                              children: self.menuItems(for: indexPath))
        })
        return config
    }
    
    @available(iOS 13.0, *)
    override func tableView(
        _ tableView: UITableView, willPerformPreviewActionForMenuWith
        configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let id = configuration.identifier as? String,
            let row = Int(id) else { return }
        openRow = row
        animator.addCompletion {
            guard let controller = self.previewController,
                row == self.previewRow else {
                    self.performSegue(withIdentifier: "showChecklistSegue", sender: self.checklists[row])
                    return
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func previewProvider(for path: IndexPath) -> ChecklistViewController {
        let controller = storyboard!.instantiateViewController(withIdentifier: "CheckListViewController") as! ChecklistViewController
        controller.dataController = dataController
        controller.checklist = checklists[path.row]
        openRow = path.row
        return controller
    }
    
    @available(iOS 13.0, *)
    func menuItems(for path: IndexPath) -> [UIMenuElement] {
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "bin.xmark"), identifier: nil, attributes: .destructive, state: .off, handler: { _ in
            self.removeList(at: path)
        })
        let deleteMenu = UIMenu(title: "", options: .displayInline, children: [delete])
        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), identifier: nil, attributes: [], state: .off, handler: { _ in
            self.performSegue(withIdentifier: "listDetailSegue", sender: path)
        })
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus.circle"), identifier: nil, attributes: [], state: .off, handler: { _ in
            self.openRow = path.row
            self.performSegue(withIdentifier: "AddItemSegue", sender: self.checklists[path.row])
        })
        
        let menu = UIMenu(title: "", options: .displayInline, children: [addItem, edit])
        
        return [menu, deleteMenu]
    }
}
