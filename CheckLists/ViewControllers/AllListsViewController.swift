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
        
        // register this controller to show previews
        registerForPreviewing(with: self, sourceView: tableView)
        
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
            if let checklist = sender as? Checklist {
                controller.checklist = checklist
                controller.dataModel = dataModel
                openedIndex = checklists.firstIndex(of: checklist)
            } else if let data = sender as? [String: Any],
                let checklist = data["checklist"] as? Checklist,
                let item = data["listItem"] as? ChecklistItem {
                controller.checklist = checklist
                controller.item = item
                controller.dataModel = dataModel
                openedIndex = checklists.firstIndex(of: checklist)
            }
        } else if segue.identifier == "listDetailSegue" {
            let navController = segue.destination as! UINavigationController
            if let controller = navController.topViewController as? ListDetailViewController {
                controller.delegate = self
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
    
    // MARK:- preview delegates
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let controller = checklistViewController(for: checklists[indexPath.row])
            openedIndex = indexPath.row
            return controller
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    // MARK:- member functions
    
    func loadData() {
        showIndicator(for: .loading)
        dataModel.getLists { [weak self] state in
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
    
    func checklistViewController(for checklist: Checklist) -> ChecklistViewController? {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "CheckListViewController") as? ChecklistViewController else {
            return nil
        }
        vc.checklist = checklist
        vc.dataModel = dataModel
        return vc
    }
    
    func removeList(at path: IndexPath) {
        let list = checklists.remove(at: path.row)
        showIndicator(for: .loading)
        dataModel.removeList(list) { [weak self] state in
            self?.showIndicator(for: state)
            guard let self = self,
                case DataState.success(_) = state else { return }
            self.tableView.deleteRows(at: [path], with: .left)
        }
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
