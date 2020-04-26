//
//  ListDetailViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit
import JGProgressHUD

typealias DidFinishSaving = (Checklist) -> Void

class ListDetailViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var doneBarButton: UIBarButtonItem?
    @IBOutlet weak var iconCell: UITableViewCell!
    
    var dataController: DataController!
    var didFinishSaving: DidFinishSaving?
    var checklist: Checklist?
    var iconName = "No Icon"
    var hud: JGProgressHUD?

    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checklist = checklist {
            title = "Edit Item"
            titleTextField?.text = checklist.title
            iconName = checklist.iconName
        }
        iconCell.imageView?.image = UIImage(named: iconName)
        iconCell.imageView?.tintColor = .systemPurple
        iconCell.textLabel?.text = iconName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pickIconSegue" {
            let controller = segue.destination as? IconPickerViewController
            controller?.didPick = { [weak self] iconName in
                guard let self = self else { return }
                self.doneBarButton?.isEnabled = true
                self.checklist?.iconName = iconName
                self.iconName = iconName
                self.iconCell.imageView?.image = UIImage(named: iconName)
                self.iconCell.imageView?.tintColor = .systemPurple
                self.iconCell.textLabel?.text = iconName
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleTextField?.becomeFirstResponder()
    }
    
    // MARK:- table view methods
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        return indexPath.section == 0 ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:- text field delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text ?? ""
        let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: string)
        doneBarButton?.isEnabled = !newText.isEmpty
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton?.isEnabled = false
        return true
    }
    
    func saveList(_ list: Checklist) {
        showIndicator(for: .loading)
        dataController.setList(list) { [weak self] state in
            self?.showIndicator(for: state)
            guard case DataState.success(_) = state else { return }
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            guard self.checklist == nil else {
                self.didFinishSaving?(list)
                return
            }
            self.didFinishSaving?(list)
        }
    }
    
    fileprivate func showIndicator(for state: DataState) {
        hud?.dismiss()
        hud = HudView.showIndicator(for: state, in: view)
    }
    
    // MARK:- IBActions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let checklist = checklist else {
            let list = Checklist(title: titleTextField?.text ?? "", iconName: iconName)
            saveList(list)
            return
        }
        checklist.title = titleTextField?.text ?? ""
        saveList(checklist)
    }
}
