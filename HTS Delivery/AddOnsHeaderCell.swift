//
//  AddOnsHeaderCell.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 3/5/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class AddOnsHeaderCell: UITableViewCell {
    
    var onChangeQuantityPressed:((AddOnsHeaderCell)->Void)?
    
    @IBOutlet weak var getQuantity: UIStepper!
    @IBOutlet weak var imageViewHeaders: UIImageView!
    
    @IBOutlet weak var designation: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    @IBAction func changeQuantity(_ sender: UIStepper) {
        
        if let onChangeQuantityPressed = self.onChangeQuantityPressed
        {
        onChangeQuantityPressed(self)
            
        }
        
         quantity.text = String(Int(sender.value))
            
       
    }
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
