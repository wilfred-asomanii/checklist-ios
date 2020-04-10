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

class ListDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var doneBarButton: UIBarButtonItem?

    weak var delegate: ListDetailDelegate?
    var checklist: Checklist?

    // MARK:- view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if let checklist = checklist {
            title = "Edit Item"
            titleTextField?.text = checklist.title
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleTextField?.becomeFirstResponder()
    }

    // MARK:- table view methods
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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

    // MARK:- IBActions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func done(_ sender: Any) {
        guard let checklist = checklist else {
            delegate?.listDetailView(self, addedChecklist: Checklist(title: titleTextField?.text ?? ""))
            dismiss(animated: true, completion: nil)
            return
        }
        checklist.title = titleTextField?.text ?? ""
        delegate?.listDetailView(self, editedChecklist: checklist)
        dismiss(animated: true, completion: nil)
    }
}
