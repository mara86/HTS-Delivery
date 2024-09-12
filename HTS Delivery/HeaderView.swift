//
//  HeaderView.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/15/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    
    override  func awakeFromNib() {
        logoImageView.layer.cornerRadius=logoImageView.frame.width/2
        
    }
}
