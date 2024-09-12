//
//  CartCell.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 11/30/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    var onButtonPlusPressed:((UITableViewCell)->Void)?
    var onButtonMinusPressed:((UITableViewCell)->Void)?
    var onButtonDeletePressed:((UITableViewCell)->Void)?
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemDetails: UILabel!
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var itemName: UILabel!
    var downloadTask: URLSessionDownloadTask?
    
    @IBAction func deleteItem(_ sender: Any) {
        if let onButtonDeletePressed = self.onButtonDeletePressed
        {
            onButtonDeletePressed(self)
        }
    }
    @IBAction func minus(_ sender: Any) {
        if let onButtonMinusPressed = self.onButtonMinusPressed
        {
            onButtonMinusPressed(self)
        }

        
    }
    @IBAction func plus(_ sender: Any) {
        if let onButtonPlusPressed = self.onButtonPlusPressed
        {
            onButtonPlusPressed(self)
        }

        
    }
    
 @IBOutlet weak var quantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        quantity.text = nil
        itemName.text = nil
        itemImageView.image = nil
    }


}
