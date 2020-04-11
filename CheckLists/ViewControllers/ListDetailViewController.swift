//
//  ListDetailViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

protocol ListDetailDelegate: class {
    func listDetailView(_ viewController: ListDetailViewController, addedChecklist list: Checklist)
    func listDetailView(_ viewController: ListDetailViewController, editedChecklist list: Checklist)
}

import UIKit

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var doneBarButton: UIBarButtonItem?
    @IBOutlet weak var iconCell: UITableViewCell!

    weak var delegate: ListDetailDelegate?
    var checklist: Checklist?
    var iconName = "No Icon"

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

    // MARK:- icon picker delegate
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        doneBarButton?.isEnabled = true
        checklist?.iconName = iconName
        self.iconName = iconName

        // alwayTemplate redering mode allows image tint to be changed regardless of the original image colors
        // this can also be changed in the Asset's attributes
//        iconCell.imageView?.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
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
            delegate?.listDetailView(self, addedChecklist: Checklist(title: titleTextField?.text ?? "", iconName: iconName))
            dismiss(animated: true, completion: nil)
            return
        }
        checklist.title = titleTextField?.text ?? ""
        delegate?.listDetailView(self, editedChecklist: checklist)
        dismiss(animated: true, completion: nil)
    }
}
