//
//  SellerTableViewCell.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 3/24/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class SellerTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var sellerImageView: UIImageView!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var cuisineType: UILabel!
    @IBOutlet weak var details: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius = logoImageView.frame.width/2
        logoImageView.layer.cornerRadius=radius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sellerImageView.image=nil
        logoImageView.image=nil
    }

}
