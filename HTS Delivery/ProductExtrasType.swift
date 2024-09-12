//
//  ProductExtras.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/8/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class ProductExtrasType: Codable {
    
    @objc(_TtCC12FlickrSearch17ProductExtrasType13ProductExtras)class ProductExtras:NSObject,NSCoding,Codable {
        var id:String
        var name:String
        var price:String
        var categoryId:String?
        var extraTypeId:String
        
        private enum CodingKeys: String, CodingKey {
                    case id
                    case name
                    case price
                    case categoryId = "category_id"
                    case extraTypeId = "extra_type_id"
        }
        init(id:String,name:String,price:String,categoryId:String?,extraTypeId:String) {
            self.id=id
            self.name=name
            self.price=price
            self.categoryId=categoryId
            self.extraTypeId=extraTypeId
        }
        
        required  convenience init?(coder aDecoder: NSCoder) {
            let id = aDecoder.decodeObject(forKey: "id") as! String
            let name = aDecoder.decodeObject(forKey: "name") as! String
            let price = aDecoder.decodeObject(forKey: "price") as! String
            let categoryId = aDecoder.decodeObject(forKey: "category_id") as? String
            let extrasTypeId = aDecoder.decodeObject(forKey: "extra_type_id") as! String
            self.init(id: id, name: name, price: price, categoryId: categoryId, extraTypeId: extrasTypeId)
            
        }
        func encode(with aCoder: NSCoder) {
            aCoder.encode(id, forKey: "id")
            aCoder.encode(name, forKey: "name")
            aCoder.encode(price, forKey: "price")
            aCoder.encode(categoryId, forKey: "category_id")
            aCoder.encode(extraTypeId, forKey: "extra_type_id")

            
            
        }
                   
                    
                  
                    
        
    }
    
    var id:String
    var extraTypeName:String
    var max=""
    var extras=[ProductExtras]()
    
    private enum CodingKeys: String, CodingKey {
                case id
                case extraTypeName = "extra_type_name"
                case extras
                case max
    }
               
                
              
                
    
    
    
    
}
