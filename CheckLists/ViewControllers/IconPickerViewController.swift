//
//  IconPickerViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 10/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

protocol IconPickerViewControllerDelegate: class {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
}

class IconPickerViewController: UITableViewController {

    var pickerDelegate: IconPickerViewControllerDelegate?

    let icons = [ "No Icon", "Appointments", "Birthdays", "Chores",
     "Drinks", "Folder", "Groceries", "Inbox", "Photos", "Trips" ]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source / delegaete methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath)

        cell.textLabel?.text = icons[indexPath.row]
        cell.imageView?.image = UIImage(named: icons[indexPath.row])?.withTintColor(.systemPurple)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pickerDelegate?.iconPicker(self, didPick: icons[indexPath.row])
    }
}