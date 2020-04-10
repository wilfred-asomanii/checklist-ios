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

    var dataModel: DataModel!

    // MARK:- View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentier)

        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistSegue" {
            let controller = segue.destination as! ChecklistViewController
            if let checklist = sender as? Checklist {
                controller.checklist = checklist
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

    // MARK: - Table view data source / delegates

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataModel.checklists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        cell.accessoryType = .disclosureIndicator
        configureCheckMarkNText(for: cell, with: dataModel.checklists[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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
    func configureCheckMarkNText(for cell: UITableViewCell, with item: Checklist) {

        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "Has a number of items"
    }

    func swipeActionTapped(action: UIContextualAction, view: UIView, handler: @escaping (Bool) -> Void, indexPath: IndexPath) {
        let title = action.title ?? ""

        if title == "Edit" {
            performSegue(withIdentifier: "listDetailSegue", sender: indexPath)
        } else if title == "Delete" {
            dataModel.checklists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        handler(true)
    }
}
