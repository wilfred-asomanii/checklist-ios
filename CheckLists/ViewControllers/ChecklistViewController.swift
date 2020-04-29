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

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- instance variables/properties
    var didAction: DidAction?
    var checklist: Checklist!
    var item: ChecklistItem? // this will be passed if a notification of said item is tapped
    var dataController: DataController!
    var hud: JGProgressHUD?
    
    private lazy var dataSource: ChecklistItemsDataSource = {
        let dS = ChecklistItemsDataSource(for: checklist, dataController: dataController)
        
        dS.itemRemoved = { [weak self] path in
            self?.tableView.deleteRows(at: [path], with: .left) }
        dS.editTapped = { [weak self] path in
            self?.performSegue(withIdentifier: "EditItemSegue", sender: self?.tableView.cellForRow(at: path))
        }
        return dS
    }()
    
    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButtonItem.action = #selector(toggleEditting)
        navigationItem.rightBarButtonItems?.append(editButtonItem)

        tableView.tableFooterView = UIView()
        tableView.register(RemindItemCell.self, forCellReuseIdentifier: ChecklistItemsDataSource.remindCellID)
        tableView.register(ItemCell.self, forCellReuseIdentifier: ChecklistItemsDataSource.cellID)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
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
    
    @objc func toggleEditting() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButtonItem.title = tableView.isEditing ? "Done": "Edit"
    }
    
    func initItemViewSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let controller = navController.topViewController as! ItemViewController
        controller.didFinishSaving = { [weak self] item, _ in
            guard let self = self else { return }
            guard let index = self.dataSource.items.firstIndex(of: item) else {
                // add
                let path = IndexPath(row: self.dataSource.items.count, section: 0)
                self.dataSource.items.append(item)
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
            controller.itemToEdit = dataSource.items[indexPath.row]
        }
    }
    
    func loadData() {
        showIndicator(for: .loading)
        dataController.getListItems(in: checklist.listID) { [weak self] state in
            self?.hud?.indicatorView = JGProgressHUDSuccessIndicatorView()
            self?.hud?.dismiss(afterDelay: 0.7, animated: true)
            if case DataState.success(let items as [ChecklistItem]) = state {
                self?.dataSource.items = items
                self?.dataSource.items = items
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
