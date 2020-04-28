//
//  IconPickerViewController.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 10/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

typealias DidPickIcon = (String) -> Void

class IconPickerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let icons = [ "No Icon", "Appointments", "Birthdays", "Chores",
                  "Drinks", "Folder", "Groceries", "Inbox", "Photos", "Trips" ]
    var didPick: DidPickIcon?
    private lazy var dataSource = {
        return DataSource(icons)
    }()
    private lazy var delegate = {
        return Delegate(icons, didPick: didPick)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "iconCell")
        tableView.dataSource = dataSource
        tableView.delegate = delegate
    }
}

private class Delegate: NSObject, UITableViewDelegate {
    let didPick: DidPickIcon?
    let icons: [String]
    
    init(_ icons: [String], didPick: DidPickIcon? = nil) {
        self.didPick = didPick
        self.icons = icons
        super.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didPick?(icons[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

private class DataSource: NSObject, UITableViewDataSource {
    
    let icons: [String]
    
    init(_ icons: [String]) {
        self.icons = icons
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath)
        
        cell.textLabel?.text = icons[indexPath.row]
        cell.imageView?.image = UIImage(named: icons[indexPath.row])
        cell.imageView?.tintColor = .systemPurple
        
        return cell
    }
}
