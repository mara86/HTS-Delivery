//
//  OrderTypeCell.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 6/6/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class OrderTypeCell: UITableViewCell {

    @IBOutlet weak var orderType: UILabel!
    @IBOutlet weak var address: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
