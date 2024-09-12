//
//  DeliveryInfo.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 6/2/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class DeliveryInfo
{
    var firstName:String?
    var lastName:String?
    var telephone:String?
    var instructions:String?
    var address:String?
    var apt:String?
    var type:String?
    var id=0
    var market:Market?
    
    var invoiceUrl:URL?
   
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithErrorAndStatus = (Bool,Error?,HTTPURLResponse?) -> Void
    
    func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/order/orderRequestByCustomer.php")!
           
       }
    
    func urlPayDunya()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/order/placeOrderPaydunya.php")!
           
       }
    
    func urlCash()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/order/orderRequestedByCustomerCash.php")!
           
       }
    
    
    
    
    public  func requestDelivery(orderInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
    {
     
        let url = self.url()
        let data_to_server=orderInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        var errorMessage:NSError?
        var errorCode=0
        
      
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
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
                    completion(success,error,response as? HTTPURLResponse)
            }
            
            
        })
        dataTask?.resume()
        
    }
    
    public  func requestDeliveryPaydunya(orderInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
    {
     
        let url = self.urlPayDunya()
        let data_to_server=orderInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        
      
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            guard let _ = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
                print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
                return
            }
               
                if let data = data {
                    do
                    {
                        let json=try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        if let json=json, let url = json["url"] as? String
                        {
                        print("**********\(url)**********")
                        if let url = URL(string: url)
                            {
                            self.invoiceUrl=url
                           
                           
                        }
                      
                        }
                        else
                        {
                            print("Not fetched")
                        }
                    }
                    catch
                    {
                        print("JSON Error: \(error)")
                       
                    }
                    
                }

           
                success = true
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,error,response as? HTTPURLResponse)
            }
            
            
        })
        dataTask?.resume()
        
    }
    
    public  func requestDeliveryCash(orderInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
    {
     
        let url = self.urlCash()
        let data_to_server=orderInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        
      
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            guard let _ = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
                print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
                completion(success,error,response as? HTTPURLResponse)
                return
            }

           
                success = true
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,error,response as? HTTPURLResponse)
            }
            
            
        })
        dataTask?.resume()
        
    }
}
