//
//  CustomerOrderTableViewCell.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/23/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CustomerOrderTableViewCell: UITableViewCell {
    
      @IBOutlet weak var orderNumberLabel: UILabel!
       @IBOutlet weak var sellerLabel: UILabel!
       @IBOutlet weak var courierLabel: UILabel!
       

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
