//
//  Hours.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 3/11/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Hours:NSObject,Codable
{
    class Day:Codable
    {
    var day:String?
    var hours:String?
        
    }
    var days:[Day]?
    var currentDay=""
    var currentTime=""
    var status=""
    var open=""
    var close=""
   
    
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    var hours:Hours?
    
  
    
    func url()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/hours/readSellerHours.php")!
        
    }
     
    
    private enum CodingKeys: String, CodingKey {
          case days
          case currentDay="current_day"
          case currentTime="current_time"
          case status
          case open
          case close
         
          
        
          
      }
   
   
   
    
    public func readHours(sellerId:String, completion:@escaping SearchCompleteWithError)
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
                    print("Big error \(error?.localizedDescription)")
                
                     completion(success,error)
             
                  
                   return
                   
               }
               do
               {
                   success = true
                   let decoder = JSONDecoder()
                   self.hours = try decoder.decode(Hours.self, from: data)
               
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
    func parseJSON( _ data: Data)-> [String:AnyObject]?
    {
        
        do
        {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        }
        catch
        {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
   
    
    
    
}
