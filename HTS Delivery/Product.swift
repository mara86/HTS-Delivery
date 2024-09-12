//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Moussa Hamet DEMBELE on 4/15/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit
class Product:NSObject, NSCoding,Codable,NSSecureCoding
{
    static var supportsSecureCoding=true
    
    class Products: Codable {
        var products=[Product]()
    }
    var itemId = ""
    var designation = ""
    var price = ""
    var desc = ""
    var imageUrl = ""
    var quantity = 0
    var categoryName:String?
    var categoryId=0
    var addons : [String]?
    var products=[Product]()
    var productsArray:Products?
    var productSubCategories=[ProductSubcategoryGroup.SubCategory]()
    var productExtras=[ProductExtrasType.ProductExtras]()
    var itemInstructions:String?
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    
    func url()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/product/read_seller_products.php")!
        
    }
     
    
    private enum CodingKeys: String, CodingKey {
          case itemId = "item_id"
          case designation
          case price
          case desc = "description"
          case imageUrl = "image_url"
          case categoryName = "category_name"
          case categoryId = "category_id"
          
        
          
      }
    
    
    init(itemId:String,designation:String,price:String,desc:String,imageUrl:String,quantity:Int, addons:[String]?,categoryId:Int,categoryName:String?,productExtras:[ProductExtrasType.ProductExtras]?,productSubCategories:[ProductSubcategoryGroup.SubCategory]?,itemInstructions:String) {
        super.init()
        self.itemId = itemId
        self.designation = designation
        self.price = price
        self.desc = desc
        self.imageUrl = imageUrl
        self.quantity = quantity
        self.addons = addons
        self.categoryId=categoryId
        self.categoryName=categoryName
        self.itemInstructions=itemInstructions
        if let productExtras=productExtras
        {
        self.productExtras=productExtras
        }
        if let productSubCategories=productSubCategories
        {
            self.productSubCategories=productSubCategories
        }
        
    }
    required  init?(coder aDecoder: NSCoder) {
        self.itemId = aDecoder.decodeObject(forKey: "itemId") as! String
        self.designation = aDecoder.decodeObject(forKey: "designation") as! String
        self.price = aDecoder.decodeObject(forKey: "price") as! String
        self.desc = aDecoder.decodeObject(forKey: "desc") as! String
        self.imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as! String
        self.quantity = Int(aDecoder.decodeInt32(forKey: "quantity"))
        self.addons = aDecoder.decodeObject(forKey: "addons") as? [String]
        self.categoryName = aDecoder.decodeObject(forKey: "categoryName") as? String
        self.categoryId = Int(aDecoder.decodeInt32(forKey: "categoryId"))
        self.productSubCategories = aDecoder.decodeObject(forKey: "productSubCategories") as! [ProductSubcategoryGroup.SubCategory]
        self.productExtras = aDecoder.decodeObject(forKey: "productExtras") as! [ProductExtrasType.ProductExtras]
        self.itemInstructions=aDecoder.decodeObject(forKey: "itemInstructions") as? String
        
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(itemId, forKey: "itemId")
        aCoder.encode(designation, forKey: "designation")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(addons,forKey: "addons")
        aCoder.encode(categoryId,forKey: "categoryId")
        aCoder.encode(categoryName,forKey: "categoryName")
        aCoder.encode(productExtras, forKey: "productExtras")
        aCoder.encode(productSubCategories, forKey: "productSubCategories")
        aCoder.encode(itemInstructions, forKey: "itemInstructions")

        
        
    }
    
    public  func getSellerProducts(sellerId:Int,completion:@escaping SearchCompleteWithError)
    {
        var sellerInfo=[String:Any]()
        sellerInfo["seller_id"]=sellerId;
        var rawData: Data?
        var myString=""
        if JSONSerialization.isValidJSONObject(sellerInfo) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: sellerInfo, options: .init(rawValue: String.Encoding.utf8.rawValue))
                let st = NSString(data: rawData!, encoding: String.Encoding.utf8.rawValue)
                myString = st as! String
                print(myString)
            } catch {
                print("Problem")
            }
        }
        let url = self.url()
        let data_to_server=myString
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
         guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
            
            print("Big error")
            completion(success,errorMessage)
                return
                
            }
            do
            {
                success = true
                let decoder = JSONDecoder()
                self.productsArray = try decoder.decode(Products.self, from: data)
                if let products=self.productsArray
             {
                self.products = products.products
             }
            }
            catch let err
            {
                print("Err", err)
                errorMessage = err
            }
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,errorMessage)
            }
            
            
        })
        dataTask?.resume()
        
    }
    
    }

func < (lhs: Product, rhs: Product)-> Bool
{
    return lhs.itemId.localizedStandardCompare(rhs.itemId) == .orderedAscending
}
