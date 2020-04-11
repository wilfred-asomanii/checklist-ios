//
//  AllListsViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import UserNotifications

// UIViewControllerPreviewingDelegate allows for previewing popup content
class AllListsViewController: UITableViewController, ListDetailDelegate, UINavigationControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

    // MARK:- variables
    let cellIdentier = "list-cell"
    let searchController = UISearchController(searchResultsController: nil)

    var dataModel: DataModel!
    var searchMatches = [Checklist]()
    var openedIndex: Int? // the index of a list that has been clicked
    var isSearching: Bool {
        get {
            return searchController.searchBar.text != nil && searchController.searchBar.text!.count > 0
        }
    }

    // MARK:- View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentier)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let openedIndex = openedIndex {
            // reload only the cell that was clicked
            tableView.reloadRows(at: [IndexPath(row: openedIndex, section: 0)], with: .automatic)
        }
        navigationController?.delegate = self

        let prevIndex = dataModel.prevSelectedIndex
        guard prevIndex >= 0, prevIndex < dataModel.checklists.count else { return }
        performSegue(withIdentifier: "showChecklistSegue", sender: dataModel.checklists[prevIndex])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistSegue" {
            let controller = segue.destination as! ChecklistViewController
            if let checklist = sender as? Checklist {
                controller.checklist = checklist
                controller.dataModel = dataModel
                openedIndex = dataModel.checklists.firstIndex(of: checklist)
            } else if let data = sender as? [String: Any],
                let checklist = data["checklist"] as? Checklist,
                let item = data["listItem"] as? ChecklistItem {
                controller.checklist = checklist
                controller.item = item
                controller.dataModel = dataModel
                openedIndex = dataModel.checklists.firstIndex(of: checklist)
            }
        } else if segue.identifier == "listDetailSegue" {
            let navController = segue.destination as! UINavigationController
            if let controller = navController.topViewController as? ListDetailViewController {
                controller.delegate = self
                if let path = sender as? IndexPath {
                    controller.checklist = dataModel.checklists[path.row]
                }
            }
        }
    }

    // search delegate
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadSections([0], with: .automatic)
    }

    // MARK:- navigation controller delegates
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // this method is called before viewDidAppear(_:animated:)
        if viewController === self {
            dataModel.prevSelectedIndex = -1
        }
    }

    // MARK:- Table view data source / delegates

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard isSearching else {
            return dataModel.checklists.count
        }

        let searchText = searchController.searchBar.text ?? ""
        searchMatches = dataModel.checklists.filter { list in
            return list.title.lowercased().contains(searchText.lowercased())
        }

        return searchMatches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let with = isSearching ? searchMatches[indexPath.row] : dataModel.checklists[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier) else {
            let newCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentier)
            newCell.accessoryType = .disclosureIndicator
            configureCheckMarkNText(for: newCell, with: with)
            return newCell
        }
        cell.accessoryType = .disclosureIndicator
        configureCheckMarkNText(for: cell, with: with)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isSearching {
            dataModel.prevSelectedIndex = indexPath.row
        }

        performSegue(withIdentifier: "showChecklistSegue", sender: dataModel.checklists[indexPath.row])
        /*
         // an alternative to segue
         // the identifier here is the storyboard ID of the controller
         let controller = storyboard!.instantiateViewController(identifier: "ChecklistViewController") as! ChecklistViewController
         controller.checklist = dataModel.checklists[indexPath.row]
         navigationController?.pushViewController(controller, animated: true)
         // or
         //                present(controller, animated: true, completion: nil)
         */
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.checklists.remove(at: indexPath.row) // remove from list first
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
        return 80
    }

    // MARK:- preview delegates

    // this is called first when user "request" preview of table cell
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // location here is the location of the cell so it can be used to fetch indexpath
        if let indexPath = tableView.indexPathForRow(at: location) {
            // make the source of the preview popup the cell in question, at this indexpath
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

            // create and return the preview controller
            let controller = checklistViewController(for: dataModel.checklists[indexPath.row])
            return controller
        }
        return nil
    }

    // this method is called when the user "requests" to "open" the preview in full
    // here, you navigate to that contoller, which is the controller returned form previewingContext(_:viewControllerForLocation:)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

    // MARK:- list detail delegates
    func listDetailView(_ viewController: ListDetailViewController, editedChecklist list: Checklist) {
        navigationController?.popViewController(animated: true)

        if let index = dataModel.checklists.firstIndex(of: list) {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                configureCheckMarkNText(for: cell, with: list)
            }
        }
    }

    func listDetailView(_ viewController: ListDetailViewController, addedChecklist list: Checklist) {
        navigationController?.popViewController(animated: true)
        let indexPath = IndexPath(row: dataModel.checklists.count, section: 0)
        dataModel.checklists.append(list)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK:- member functions

    // return a ChecklistViewController to display content of a checklist
    func checklistViewController(for checklist: Checklist) -> ChecklistViewController? {
        // you cannot just create an object of the controller yourself, use storyboard to do that, it'll instantiate the view as well, given the soryboard id of the controller.
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "CheckListViewController") as? ChecklistViewController else {
            return nil
        }

        // prepare necessary properties
        vc.checklist = checklist
        vc.dataModel = dataModel
        return vc
    }

    func configureCheckMarkNText(for cell: UITableViewCell, with item: Checklist) {
        let initialtext =   item.title
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: initialtext)

        var ranges: [Range<String.Index>] = []
        while ranges.last.map({ $0.upperBound < initialtext.endIndex}) ?? true,
            let range = initialtext.range(of: searchController.searchBar.text ?? "", options: .caseInsensitive, range: (ranges.last?.upperBound ?? initialtext.startIndex)..<initialtext.endIndex, locale: .current) {
            ranges.append(range)
        }

        for r in ranges {
            attrString.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: NSRange(r, in: initialtext))
            attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange(r, in: initialtext))
        }

        cell.textLabel?.attributedText = attrString
        cell.imageView?.image = UIImage(named: item.iconName)
        cell.imageView?.tintColor = .systemPurple

        // the function parameter can be written outside the paretheses
        let count = item.items.filter() { it in
            return !it.isChecked
        }.count

        switch count {
        case let x where x == 0 && item.items.count > 0:
            cell.detailTextLabel?.text = "All done 🎊!"
        case let x where x == 0 && item.items.count == 0:
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
            let deletedList = dataModel.checklists.remove(at: indexPath.row)
            for item in deletedList.items {
                if item.shouldRemind {
                    item.shouldRemind = false
                    dataModel.toggleNotification(for: item, inList: deletedList.listID)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        handler(true)
    }

    func notificationTapped(for itemID: Int, inList listID: Int) {
        let checklist = dataModel.checklists.first { list in
            return list.listID == listID
        }

        guard let list = checklist else { return }
        let listItem = list.items.first { item in
            return item.itemID == itemID
        }
        guard let item = listItem else { return }
        let topView = navigationController?.topViewController as? AllListsViewController
        if topView == nil {
            // this controller is not the topmost view so pop
            navigationController?.popToRootViewController(animated: true)
        }

        dismiss(animated: true, completion: nil) // in case there's a modal over this controller
        performSegue(withIdentifier: "showChecklistSegue", sender: ["checklist": list, "listItem": item])
    }
}
