//
//  DiaryTableViewCell.swift
//  SCI_Aid
//
//  Created by Dee on 29/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var warningImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
