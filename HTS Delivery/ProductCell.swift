//
//  FlickrPhotosCell.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 11/23/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import Foundation

class ProductCell: UICollectionViewCell {

    var onButtonPressed:((UICollectionViewCell)->Void)?
    var downloadTask:URLSessionDownloadTask?
    @IBOutlet weak var addToCart: UIButton!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func addToCart(_ sender: AnyObject) {
        
        if let onButtonPressed = self.onButtonPressed
        {
            onButtonPressed(self)
        }
    }
    override func prepareForReuse() {
           super.prepareForReuse()
           downloadTask?.cancel()
           imageView.image=nil
           desc.text=nil
           price.text=nil
       }
    
}
