//
//  SavedCardTableViewCell.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 1/9/24.
//  Copyright © 2024 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class SavedCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardExpDate: UILabel!
    @IBOutlet weak var cardName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
