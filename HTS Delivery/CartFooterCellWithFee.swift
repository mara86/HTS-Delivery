//
//  CartFooterCell.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/26/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CartFooterCellWithFee: UITableViewCell {
    @IBOutlet weak var deliveryFee: UILabel!
    @IBOutlet weak var subtotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var total: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
