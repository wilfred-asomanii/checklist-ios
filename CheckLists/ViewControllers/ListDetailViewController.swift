//
//  ListDetailViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var doneBarButton: UIBarButtonItem?
    @IBOutlet weak var iconCell: UITableViewCell!
    
    var dataModel: DataModel!
    weak var delegate: ListDetailViewControllerDelegate?
    var checklist: Checklist?
    var iconName = "No Icon"
    var hud: HudView?
    
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
            controller?.pickerDelegate = self
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
        dataModel.setList(list) { [weak self] state in
            self?.showIndicator(for: state)
            guard case DataState.success(_) = state else { return }
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            guard self.checklist == nil else {
                self.delegate?.listDetailViewController(self, didFinishEditing: list)
                return
            }
            self.delegate?.listDetailViewController(self, didFinishAdding: list)
        }
    }
    
    fileprivate func showIndicator(for state: DataState) {
        hud?.removeFromSuperview()
        hud = HudView.hud(inView: presentingViewController!.view,
                              animated: true, state: state)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.hud?.hide()
        }
    }
    
    // MARK:- icon picker delegate
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        doneBarButton?.isEnabled = true
        checklist?.iconName = iconName
        self.iconName = iconName
        
        iconCell.imageView?.image = UIImage(named: iconName)
        iconCell.imageView?.tintColor = .systemPurple
        iconCell.textLabel?.text = iconName
        navigationController?.popViewController(animated: true)
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
