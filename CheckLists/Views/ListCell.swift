//
//  ListCell.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 25/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with item: Checklist, highlight: String = "") {
        accessoryType = .disclosureIndicator
        let title = item.title
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: title)
        
        let ranges = title.ranges(of: highlight)
        
        for range in ranges {
            let nsRange = NSRange(range, in: title)
            attrString.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: nsRange)
            attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: nsRange)
        }
        
        textLabel?.attributedText = attrString
        imageView?.image = UIImage(named: item.iconName)
        imageView?.tintColor = .systemPurple
        
        let count = item.pendingCount
        
        switch count {
        case let x where x == 0 && item.totalItems > 0:
            detailTextLabel?.text = "All done 🎊!"
        case let x where x == 0 && item.totalItems == 0:
            detailTextLabel?.text = "Nothing to do 🤦🏽‍♂️"
        case let x where x < 3:
            detailTextLabel?.text = "Almost there! 😬"
        default:
            detailTextLabel?.text = "\(count) things remain 🥺"
        }
    }
    

}
