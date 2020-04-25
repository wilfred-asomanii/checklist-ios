//
//  RemindItemCell.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 25/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class RemindItemCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with item: ChecklistItem) {
        textLabel?.text = item.title
        textLabel?.numberOfLines = 2
        
        accessoryType = item.isChecked ? .checkmark : .none

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        detailTextLabel?.text = "Due \(formatter.string(from: item.dueDate))"
        detailTextLabel?.textColor = item.dueDate < Date() ? .systemRed : .systemPurple
    }
}
