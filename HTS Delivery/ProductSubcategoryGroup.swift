//
//  ProductSubcategory.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/8/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class ProductSubcategoryGroup:Codable{
    
    @objc(_TtCC12FlickrSearch23ProductSubcategoryGroup11SubCategory)class SubCategory:NSObject,NSCoding, Codable {
        var id:String
        var name:String
        var price:String
        var categoryId:String?
        var subCategoryGroupId:String
        
        private enum CodingKeys: String, CodingKey {
                    case id
                    case name
                    case price
                    case categoryId="category_id"
                    case subCategoryGroupId = "sub_category_group_id"
        }
        
        init(id:String,name:String,price:String,categoryId:String,subCategoryId:String) {
            self.id=id
            self.name=name
            self.price=price
            self.categoryId=categoryId
            self.subCategoryGroupId=subCategoryId
        }
        
        
        required  init?(coder aDecoder: NSCoder) {
                   
            self.id = aDecoder.decodeObject(forKey: "id") as! String
            self.name = aDecoder.decodeObject(forKey: "name") as! String
            self.price = aDecoder.decodeObject(forKey: "price") as! String
            self.categoryId = aDecoder.decodeObject(forKey: "category_id") as? String
            self.subCategoryGroupId = aDecoder.decodeObject(forKey: "sub_category_group_id") as! String
           
                  
                   
               }
               func encode(with aCoder: NSCoder) {
                   aCoder.encode(id, forKey: "id")
                   aCoder.encode(name, forKey: "name")
                   aCoder.encode(price, forKey: "price")
                   aCoder.encode(categoryId, forKey: "category_id")
                   aCoder.encode(subCategoryGroupId, forKey: "sub_category_group_id")

                   
                   
               }
                   
                    
                  
                    
    }
    var id:String
    var name:String
    var title:String
    var subCategories=[SubCategory]()
    
    private enum CodingKeys: String, CodingKey {
                case id
                case name
                case title
                case subCategories="sub_categories"
    }
               
                
              
                
}
