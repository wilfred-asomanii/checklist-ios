//
//  ProfileViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 24/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    @IBOutlet weak var usernameCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var updateProfileCell: UITableViewCell!
    @IBOutlet weak var changePassCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    @IBOutlet weak var deletAccCell: UITableViewCell!
    
    var auth: AuthController!
    var dataController: DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = auth.currentUser!
        usernameCell.textLabel?.text = user.displayName ?? "(Username)"
        emailCell.textLabel?.text = user.email ?? "(Email)"
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? nil : indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath),
            cell == logOutCell {
            if auth.logOut() {
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
