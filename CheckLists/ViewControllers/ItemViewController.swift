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
    func itemViewController(_ controller: ItemViewController, didFinishAdding item: ChecklistItem)
    func itemViewController(_ controller: ItemViewController, didFinishEditing item: ChecklistItem)
}

/// this controller's table view is static instead of having dynamic content similar to the main screen
/// cos of this, we don't need a datasource here. we can also directly access the cell contents using outlets
class ItemViewController: UITableViewController, UITextFieldDelegate {

    // MARK:- IBOutlets
    @IBOutlet weak var doneBarButton: UIBarButtonItem?
    @IBOutlet weak var nameTextField: UITextField?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remindSwith: UISwitch!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet var datePickerCell: UITableViewCell!
    @IBOutlet weak var repeatSwitch: UISwitch!

    // MARK:- variables
    weak var itemViewDelegate: ItemViewControllerDelegate?
    var itemToEdit: ChecklistItem?
    var dueDate = Date()
    var isDatePickerVisible = false

    // MARK:- view controller delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = itemToEdit {
            title = "Edit Item"
            nameTextField?.text = item.title
            remindSwith.isOn = item.shouldRemind
            repeatSwitch.isOn = item.shouldRepeat
            dueDate = item.dueDate
            doneBarButton?.isEnabled = true
        }
        updateDateLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // this will autofocus on the text field
        nameTextField?.becomeFirstResponder()
    }

    // MARK:- Table view delegates

    @IBAction func remindMeChanged(_ sender: UISwitch) {
        if !sender.isOn {
            repeatSwitch.setOn(false, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && isDatePickerVisible {
            return 4 // the new # of cells after dynamically adding cells
        }
        // return super for section that wasn't changed
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        return indexPath.section == 1 && indexPath.row == 1 ? indexPath : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 && indexPath.row == 1 {
            toggleDatePicker()
        }
        nameTextField?.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // for a static table like this, you'll overide this method so you can add some dynamic cells
    // remember to call super for other cells in storyboard to work
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 && isDatePickerVisible {
            return datePickerCell
        }
        // return super for static cells
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // since we're adding a dynamic cell that contains a date picker and is huge, we have to return that height here
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 && isDatePickerVisible {
            return 217 // height of the date picker cell
        }
        return 50
    }

    // aslo the table view cannot find the indent of a cell that wasn't originally in the storyboard
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var cellPath = indexPath
        if cellPath.section == 1 && cellPath.row == 2 && isDatePickerVisible {
            // for this "unknowncell" use the same indentation of an already existing cell
            cellPath = IndexPath(row: 0, section: cellPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: cellPath)
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // hide datepicker when the keyboard pops up
        if isDatePickerVisible {
            hideDatePicker()
        }
    }

    // MARK:- instance functions
    func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: dueDate)
    }

    func toggleDatePicker() {
        if !isDatePickerVisible {
            showDatePicker()
        } else {
            hideDatePicker()
        }
    }

    func showDatePicker() {
        let pickerPath = IndexPath(row: 2, section: 1)
        isDatePickerVisible = true
        tableView.insertRows(at: [pickerPath], with: .fade)
        dueDatePicker.setDate(dueDate, animated: true)
        dateLabel.textColor = .systemPurple
    }

    func hideDatePicker() {
        let pickerPath = IndexPath(row: 2, section: 1)
        isDatePickerVisible = false
        tableView.deleteRows(at: [pickerPath], with: .fade)
        if #available(iOS 13.0, *) {
            dateLabel.textColor = .label
        } else {
            // Fallback on earlier versions
            dateLabel.textColor = .black
        }
    }

    // MARK:- IBActions
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        guard let item = itemToEdit else {
            // itemToEdit is nil
            let addedItem = ChecklistItem(title: nameTextField?.text ?? "", shouldRemind: remindSwith.isOn, shouldRepeat: repeatSwitch.isOn,  dueDate: dueDate)
            itemViewDelegate?.itemViewController(self, didFinishAdding: addedItem)
            dismiss(animated: true, completion: nil)
            return
        }
        // itemToEdit is not nil
        item.title = nameTextField?.text ?? ""
        item.dueDate = dueDate
        item.shouldRemind = remindSwith.isOn
        item.shouldRepeat = repeatSwitch.isOn
        itemViewDelegate?.itemViewController(self, didFinishEditing: item)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dueDate = sender.date
        updateDateLabel()
    }
}
