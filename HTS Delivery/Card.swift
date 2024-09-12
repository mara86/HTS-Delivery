//
//  Card.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 1/9/24.
//  Copyright © 2024 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Card:Codable
{
    
    
       var cardId="";
       var expirationMonth=0;
       var expirationYear=0;
       var cardBrand="";
       var last4="";
       var cardType="";
       var customerId="";
    
    private enum CodingKeys: String, CodingKey {
        
             case cardId="id"
             case expirationMonth="exp_month"
             case expirationYear="exp_year"
             case cardBrand="card_brand"
             case last4="last_4"
             case cardType="card_type"
             case customerId="customer_id"
            
             
           
             
         }
    
    
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    typealias SearchCompleteWithErrorAndStatus = (Bool,Error?,HTTPURLResponse?) -> Void
    typealias SearchCompleteWithMessage = (Bool,Error?,String) -> Void
    var cards = Cards()
    
    
    
     func urlSaveCard()->URL
       {


           let url =  URL(string:"https://www.htsdelivery.com/api/card/saveCard.php");

           return url!

       }

       public func urlRetrieveCards()->URL
       {


          let url =  URL(string: "https://www.htsdelivery.com/api/card/retrieveCustomerCards.php");

           return url!

       }
    
    
    public  func retriveCards(customerInfo:String,completion:@escaping SearchCompleteWithError)
       {
        
           let url = self.urlRetrieveCards()
           let data_to_server=customerInfo
           var request = URLRequest(url: url)
           request.httpMethod="POST"
           request.httpBody=data_to_server.data(using: String.Encoding.utf8)
           dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
               , error in
               var success = false
               var errorMessage:Error?
            guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
               print("Big error")
                 completion(success,error)
                   return
                   
               }
               do
               {
                   success = true
                   let decoder = JSONDecoder()
                   self.cards = try decoder.decode(Cards.self, from: data)
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
    
    
    public  func saveCard(cardInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
       {
        
           let url = self.urlSaveCard()
           let data_to_server=cardInfo
           var request = URLRequest(url: url)
           request.httpMethod="POST"
           request.httpBody=data_to_server.data(using: String.Encoding.utf8)
           dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
               , error in
               var success = false
               var errorMessage:Error?
               var errorCode=0
               guard let _ = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
                   print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
                   if let response=response as? HTTPURLResponse
                   {
                       errorCode=response.statusCode
                       
                   }
                  
                   if let data = data {
                       do
                       {
                           let json=try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                           if let json=json, let message = json["message"] as? String
                           {
                               print(message)
                               errorMessage=NSError(domain: message, code: errorCode,userInfo: json)
                               
                               
                               
                           }
                       }
                       catch
                       {
                           print("JSON Error: \(error)")
                          
                       }
                       
                   }
                  
                   completion(success,errorMessage,response as? HTTPURLResponse)
                   return
                   
               }
               
               success = true
               
               
               
               
               
               DispatchQueue.main.async
                   {
                       UIApplication.shared.isNetworkActivityIndicatorVisible = false
                       completion(success,errorMessage,response as? HTTPURLResponse)
               }
               
               
           })
           dataTask?.resume()
           
       }
       
}
