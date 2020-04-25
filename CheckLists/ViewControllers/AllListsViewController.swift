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

class AllListsViewController: UITableViewController, UINavigationControllerDelegate, UISearchResultsUpdating {
    
    // MARK:- variables
    let cellIdentier = "list-cell"
    let searchController = UISearchController(searchResultsController: nil)
    
    var dataController: DataController!
    var checklists = [Checklist]()
    var searchMatches = [Checklist]()
    var isSearching: Bool {
        searchController.searchBar.text != nil && searchController.searchBar.text!.count > 0
    }
    var openedIndex: Int?
    var hud: HudView?
    
    // MARK:- View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = editButtonItem
        
        // search controller stuff
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search checklists"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        guard let i = openedIndex else { return }
        tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistSegue" {
            let controller = segue.destination as! ChecklistViewController
            if let cell = sender as? UITableViewCell,
                let path = tableView.indexPath(for: cell) {
                // previewing
                let checklist = checklists[path.row]
                controller.checklist = checklist
                controller.previewDelegate = self
                controller.dataController = dataController
                openedIndex = checklists.firstIndex(of: checklist)
            } else if let checklist = sender as? Checklist {
                controller.checklist = checklist
                controller.dataController = dataController
                openedIndex = checklists.firstIndex(of: checklist)
            } else if let data = sender as? [String: Any],
                let checklist = data["checklist"] as? Checklist,
                let item = data["listItem"] as? ChecklistItem {
                controller.checklist = checklist
                controller.item = item
                controller.dataController = dataController
                openedIndex = checklists.firstIndex(of: checklist)
            }
        } else if segue.identifier == "listDetailSegue" {
            let navController = segue.destination as! UINavigationController
            if let controller = navController.topViewController as? ListDetailViewController {
                controller.delegate = self
                controller.dataController = dataController
                if let path = sender as? IndexPath {
                    controller.checklist = checklists[path.row]
                }
            }
        }
    }
    
    // search delegate
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadSections([0], with: .automatic)
    }
    
    // MARK:- member functions
    
    func loadData() {
        showIndicator(for: .loading)
        dataController.getLists { [weak self] state in
            self?.showIndicator(for: state)
            guard case DataState.success(let lists as [Checklist]) = state  else { return }
            self?.checklists = lists
            guard lists.count > 0 else { return }
            self?.tableView.reloadSections([0], with: .automatic)
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
    
    func removeList(at path: IndexPath) {
        let list = checklists.remove(at: path.row)
        dataController.removeList(list)
        self.tableView.deleteRows(at: [path], with: .left)
    }
    
    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""
        
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
        
        guard isSearching else {
            return checklists.count
        }
        
        let searchText = searchController.searchBar.text ?? ""
        searchMatches = checklists.filter { list in
            return list.title.lowercased().contains(searchText.lowercased())
        }
        
        return searchMatches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let list = isSearching ? searchMatches[indexPath.row] : checklists[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier) as! ListCell
        
        cell.configure(with: list, highlight: searchController.searchBar.text ?? "")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return checklists.count == 0 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        performSegue(withIdentifier: "showChecklistSegue", sender: checklists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return checklists.count > 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case UITableViewCell.EditingStyle.delete = editingStyle else { return }
        removeList(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard checklists.count > 0 else { return nil }
        
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
        return 80
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let list = checklists[indexPath.row]
        let provider: UIContextMenuContentPreviewProvider?
        if list.totalItems > 0 {
            provider = { return self.previewProvider(for: indexPath)}
        } else {
            provider = nil
        }
        let config = UIContextMenuConfiguration(
            identifier: "\(indexPath.row)" as NSString,
            previewProvider: provider,
            actionProvider: { _ in
                return UIMenu(title: "", children: self.menuItems(for: indexPath))
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
        animator.addCompletion {
            self.performSegue(withIdentifier: "showChecklistSegue", sender: self.checklists[row])
        }
    }
}

// MARK:- ListDetailViewControllerDelegate
extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: Checklist) {
        let path = IndexPath(row: checklists.count, section: 0)
        checklists.append(list)
        tableView.insertRows(at: [path], with: .bottom)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: Checklist) {
        guard let i = checklists.firstIndex(of: list) else { return }
        let path = IndexPath(row: i, section: 0)
        tableView.reloadRows(at: [path], with: .automatic)
    }
}

// MARK:- previewing stuff
extension AllListsViewController: CheckListPreviewDelegate {
    
    func checkListPreview(didDeleteFrom controller: ChecklistViewController) {
        guard let checklist = controller.checklist,
            let row = checklists.firstIndex(of: checklist) else { return }
        removeList(at: IndexPath(row: row, section: 0))
    }
    
    func checkListPreview(didEditFrom controller: ChecklistViewController) {
        guard let checklist = controller.checklist,
            let row = checklists.firstIndex(of: checklist) else { return }
        performSegue(withIdentifier: "listDetailSegue", sender: IndexPath(row: row, section: 0))
    }
    
    func previewProvider(for path: IndexPath) -> UIViewController {
        let controller = storyboard!.instantiateViewController(withIdentifier: "CheckListViewController") as! ChecklistViewController
        controller.dataController = dataController
        controller.checklist = checklists[path.row]
        openedIndex = path.row
        return controller
    }
    
    @available(iOS 13.0, *)
    func menuItems(for path: IndexPath) -> [UIMenuElement] {
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "bin.xmark"), identifier: nil, attributes: .destructive, state: .off, handler: { _ in
            self.removeList(at: path)
        })
        let open = UIAction(title: "Open", image: UIImage(systemName: "ellipsis.circle"), identifier: nil, attributes: [], state: .off, handler: { _ in
            self.performSegue(withIdentifier: "showChecklistSegue", sender: self.checklists[path.row])
        })
        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), identifier: nil, attributes: [], state: .off, handler: { _ in
            self.performSegue(withIdentifier: "listDetailSegue", sender: path)
        })
        return [open, edit, delete]
    }
    
}
