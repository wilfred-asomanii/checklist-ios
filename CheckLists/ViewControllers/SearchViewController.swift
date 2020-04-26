//
//  SearchViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 25/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    var lists = [Checklist]()
    var term = "" {
        didSet {
            tableView?.reloadSections([0], with: .automatic)
        }
    }
    let id = "search-cell"
    var cellTapped: ((Checklist) -> Void)?
    var cellActionTapped: ((UIContextualAction,UIView,Checklist,(Bool) -> Void) -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: id)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        configCell(cell, for: lists[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped?(lists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {action, view, handler in
            self.cellActionTapped?(action, view, self.lists[indexPath.row], handler)
        })
        editAction.backgroundColor = .systemPurple
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {action, view, handler in
            self.cellActionTapped?(action, view, self.lists[indexPath.row], handler)
            self.lists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func configCell(_ cell: UITableViewCell, for list: Checklist) {
        let title = list.title
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: title)
        
        let ranges = title.ranges(of: term)
        
        for range in ranges {
            let nsRange = NSRange(range, in: title)
            attrString.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: nsRange)
            attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: nsRange)
        }
        
        cell.tintColor = .systemPurple
        cell.textLabel?.attributedText = attrString
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: list.iconName)
    }
}
