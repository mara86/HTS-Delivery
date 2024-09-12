//
//  Size.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/8/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class SizeGroup: Codable {
    
    class Size: Codable {
        var id:Int
        var name:String
        var sizePrice:String
        var categoryId:Int
        var itemId:Int
        var designation:String
        var sizeGroupId:Int
    }
    var id:Int
    var name:String
    var sizes=[Size]()
}
