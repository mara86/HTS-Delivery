//
//  Courier.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/21/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class Courier: Codable {
    
       var firstName:String
       var lastName:String
       var longitude:String?
       var latitude:String?
       var courierId:String?
       var token:String?
       var profileImage:String?
       var telephone:String
       
       private enum CodingKeys: String, CodingKey {
        
                   case firstName = "first_name"
                   case lastName = "last_name"
                   case longitude
                   case latitude="latitude_courier"
                   case courierId="courier_id"
                   case token
                   case profileImage = "profile_image_url"
                   case telephone
                   
               }
       
       
    
}
