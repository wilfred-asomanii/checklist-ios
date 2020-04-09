//
//  AllListsViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailDelegate {

    // MARK:- variables
    let cellIdentier = "list-cell"

    var checklists = [CheckListItem]()

    // MARK:- View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        loadChecklists()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentier)

        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistSegue" {
            let controller = segue.destination as! CheckListViewController
            if let checklist = sender as? CheckListItem {
                controller.checklist = checklist
            }
        } else if segue.identifier == "listDetailSegue" {
            let navController = segue.destination as! UINavigationController
            if let controller = navController.topViewController as? ListDetailViewController {
                controller.delegate = self
                if let path = sender as? IndexPath {
                    controller.checklist = checklists[path.row]
                }
            }
        }
    }

    // MARK: - Table view data source / delegates

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return checklists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = checklists[indexPath.row].title
        cell.detailTextLabel?.text = "Has a number of items"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "showChecklistSegue", sender: checklists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        checklists.remove(at: indexPath.row) // remove from list first
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

    // MARK:- list detail delegates
    func listDetailView(_ viewController: ListDetailViewController, editedChecklist list: CheckListItem) {
        navigationController?.popViewController(animated: true)

        if let index = checklists.firstIndex(of: list) {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                configureCheckMarkNText(for: cell, with: list)
            }
        }
        saveChecklistItems()
    }

    func listDetailView(_ viewController: ListDetailViewController, addedChecklist list: CheckListItem) {
        navigationController?.popViewController(animated: true)
        let indexPath = IndexPath(row: checklists.count, section: 0)
        checklists.append(list)
        tableView.insertRows(at: [indexPath], with: .automatic)

        saveChecklistItems()
    }

    // MARK:- member functions
    func loadChecklists() {
        if let data = try? Data(contentsOf: dataFilePath()) {
            let decoder = PropertyListDecoder()
            checklists = (try? decoder.decode([CheckListItem].self, from: data)) ?? []
        }
    }

    func configureCheckMarkNText(for cell: UITableViewCell, with item: CheckListItem) {
        cell.textLabel?.text = item.title
    }

    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""

        if title == "Edit" {
            performSegue(withIdentifier: "listDetailSegue", sender: indexPath)
        } else if title == "Delete" {
            checklists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveChecklistItems()
        }
        handler(true)
    }

    func saveChecklistItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(checklists)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        // the below style, you don't need to catch the error. swift simply continues executing like nothing happened.
        // use this when you don't need to necessarily handle error
        // let data = try? encoder.encode(items)
        // try? data?.write(to: dataFilePath())
    }

}
