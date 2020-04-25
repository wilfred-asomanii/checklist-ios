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

// UIViewControllerPreviewingDelegate allows for previewing popup content
class AllListsViewController: UITableViewController, UINavigationControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    
    // MARK:- variables
    let cellIdentier = "list-cell"
    let searchController = UISearchController(searchResultsController: nil)
    
    var dataModel: DataModel!
    var state = DataState.success([Checklist]())
    var checklists = [Checklist]()
    var searchMatches = [Checklist]()
    var isSearching: Bool {
        searchController.searchBar.text != nil && searchController.searchBar.text!.count > 0
    }
    var auth: AuthController!
    var listener: ListenerRegistration?
    
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
        
        // register this controller to show previews
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        listenForData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistSegue" {
            let controller = segue.destination as! ChecklistViewController
            if let checklist = sender as? Checklist {
                controller.checklist = checklist
                controller.dataModel = dataModel
            } else if let data = sender as? [String: Any],
                let checklist = data["checklist"] as? Checklist,
                let item = data["listItem"] as? ChecklistItem {
                controller.checklist = checklist
                controller.item = item
                controller.dataModel = dataModel
            }
        } else if segue.identifier == "listDetailSegue" {
            let navController = segue.destination as! UINavigationController
            if let controller = navController.topViewController as? ListDetailViewController {
                controller.dataModel = dataModel
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
    
    // MARK:- Table view data source / delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checklists.count == 0 {
            return 1
        }
        
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
        
        if case DataState.error(let error) = state,
            (error != nil && checklists.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "errorCell")!
        }
        
        if checklists.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "emptyCell")!
        }
        
        let with = isSearching ? searchMatches[indexPath.row] : checklists[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier) else {
            let newCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentier)
            newCell.accessoryType = .disclosureIndicator
            configCell(for: newCell, with: with)
            return newCell
        }
        cell.accessoryType = .disclosureIndicator
        configCell(for: cell, with: with)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return checklists.count == 0 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showChecklistSegue", sender: checklists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return checklists.count > 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    // MARK:- preview delegates
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let controller = checklistViewController(for: checklists[indexPath.row])
            return controller
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    // MARK:- member functions
    
    func listenForData() {
        listener = dataModel.listenLists { [weak self] state in
            if case DataState.success(let lists as [Checklist]) = state {
                self?.checklists = lists
                self?.tableView.reloadSections([0], with: .automatic)
            }
            self?.state = state
        }
    }
    
    func checklistViewController(for checklist: Checklist) -> ChecklistViewController? {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "CheckListViewController") as? ChecklistViewController else {
            return nil
        }
        vc.checklist = checklist
        vc.dataModel = dataModel
        return vc
    }
    
    func removeList(at path: IndexPath) {
        dataModel.removeList(checklists[path.row])
    }
    
    func configCell(for cell: UITableViewCell, with item: Checklist) {
        let title = item.title
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: title)
        
        let ranges = title.ranges(of: searchController.searchBar.text ?? "")
        
        for range in ranges {
            let nsRange = NSRange(range, in: title)
            attrString.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: nsRange)
            attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: nsRange)
        }
        
        cell.textLabel?.attributedText = attrString
        cell.imageView?.image = UIImage(named: item.iconName)
        cell.imageView?.tintColor = .systemPurple
        
        let count = item.pendingCount
        
        switch count {
        case let x where x == 0 && item.totalItems > 0:
            cell.detailTextLabel?.text = "All done 🎊!"
        case let x where x == 0 && item.totalItems == 0:
            cell.detailTextLabel?.text = "Nothing to do 🤦🏽‍♂️"
        case let x where x < 3:
            cell.detailTextLabel?.text = "Almost there! 😬"
        default:
            cell.detailTextLabel?.text = "\(count) things remain 🥺"
        }
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
        dataModel.getList(listID) { [weak self] state in
            guard case DataState.success(let list as Checklist) = state else { return }
            self?.dataModel.getListItem(itemID) { [weak self] state in
                guard case DataState.success(let item as ChecklistItem) = state else { return }
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
}
