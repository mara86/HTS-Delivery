//
//  Category.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 3/7/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Category:Codable
{
    class Categories:Codable
    {
        var categories=[Category]()
    }
    var categoryId=0
    var categoryName=""
    var sellerId=0
    private enum CodingKeys: String, CodingKey {
        case categoryId="category_id"
        case categoryName="category_name"
        case sellerId="seller_id"
    }
    
    var categories:Categories?
    var categoryArray=[Category]()
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
       
       func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/category/read_seller_categories.php")!
           
       }
    
    public func showCategories(sellerId:Int,completion:@escaping SearchCompleteWithError)
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
        var request = URLRequest(url: url)
        let data_to_server=myString
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
         guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
                print("Big error \(error?.localizedDescription)")
                return
                
            }
            do
            {
                success = true
            let decoder = JSONDecoder()
                self.categories = try decoder.decode(Categories.self, from: data)
                if let categories=self.categories
             {
                self.categoryArray = categories.categories
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
