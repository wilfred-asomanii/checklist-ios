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
    
    var didPick: DidPickIcon?
    private lazy var dataSource = {
        return IconsDataSource(didPick: didPick)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "iconCell")
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}
