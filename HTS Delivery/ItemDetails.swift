//
//  All.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/8/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class ItemDetails: Decodable {
    var productSubcategories=[ProductSubcategoryGroup]()
    var productExtras=[ProductExtrasType]()
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    var itemDetails:ItemDetails?
    func url()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/get_item_details.php")!
        
    }
    
    private enum CodingKeys: String, CodingKey {
                case productSubcategories = "product_sub_categories"
                case productExtras = "product_extras"
    }
    
    public  func getItemDetails(itemId:String,completion:@escaping SearchCompleteWithError)
    {
        var itemInfo=[String:Any]()
        itemInfo["item_id"]=itemId;
        var rawData: Data?
        var myString=""
        if JSONSerialization.isValidJSONObject(itemInfo) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: itemInfo, options: .init(rawValue: String.Encoding.utf8.rawValue))
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
              completion(success,error)
                return
                
            }
            do
            {
                success = true
                let decoder = JSONDecoder()
                self.itemDetails = try decoder.decode(ItemDetails.self, from: data)
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
