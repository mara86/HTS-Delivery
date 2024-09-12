//
//  CartFooterView.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/24/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CartFooterView: UIView {
    
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var total: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subTotal.text="20.0"
        tax.text="1.8"
        total.text="21.8"
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
