//
//  ItemViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 08/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

// protocols are similar to interfaces in Java
// : class means only classes can use this protocol
protocol ItemViewControllerDelegate: class {
    func itemViewController(_ controller: ItemViewController, addedItem item: CheckListItem)
    func itemViewController(_ controller: ItemViewController, editedItem item: CheckListItem)
}

/// this controller's table view is static instead of having dynamic content similar to the main screen
/// cos of this, we don't need a datasource here. we can also directly access the cell contents using outlets
class ItemViewController: UITableViewController, UITextFieldDelegate {

    // MARK:- IBOutlets
    @IBOutlet weak var doneBarButton: UIBarButtonItem?
    @IBOutlet weak var nameTextField: UITextField?

    // MARK:- delegate variables
    weak var itemViewDelegate: ItemViewControllerDelegate?

    // MARK:- member variables
    var itemToEdit: CheckListItem?

    // MARK:- view controller delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = itemToEdit {
            title = "Edit Item"
            nameTextField?.text = item.title
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // this will autofocus on the text field
        nameTextField?.becomeFirstResponder()
    }

    // MARK:- Table view delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // returning nil in this method disables selection for the particular indexPath
        // the cell will briefly be highlighted though.
        return nil
    }

    // MARK:- TextField delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let oldText = textField.text!
        let editRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: editRange, with: string)
        doneBarButton?.isEnabled = !newText.isEmpty
        return true
    }

    // triggered by the clear button on the text field
    // cos the clear button does not call textField(_:shouldChangeCharactersIn:replacementString)
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton?.isEnabled = false
        return true
    }

    // MARK:- IBActions
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        //                if let item = itemToEdit {
        //                    item.title = nameTextField?.text ?? ""
        //                    itemViewDelegate?.itemViewController(self, editedItem: item)
        //         dismiss(animated: true, completion: nil)
        //                } else {
        //                let item = CheckListItem(title: nameTextField?.text ?? "", isChecked: false)
        //                itemViewDelegate?.itemViewController(self, addedItem: item)
        //        dismiss(animated: true, completion: nil)
        //            }

        // OR
        guard let item = itemToEdit else {
            // itemToEdit is nil
            let addedItem = CheckListItem(title: nameTextField?.text ?? "", isChecked: false)
            itemViewDelegate?.itemViewController(self, addedItem: addedItem)
            dismiss(animated: true, completion: nil)
            return
        }
        // itemToEdit is not nil
        item.title = nameTextField?.text ?? ""
        itemViewDelegate?.itemViewController(self, editedItem: item)
        dismiss(animated: true, completion: nil)
    }

}
