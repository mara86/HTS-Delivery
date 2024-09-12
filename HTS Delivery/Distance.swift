//
//  Distance.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 6/14/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Distance:Decodable
{
    var message=""
    var distanceInMiles=0.00
    
    var distance:Distance?
    var market:Market?
   
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithErrorAndStatus = (Bool,Error?,HTTPURLResponse?) -> Void
    
    func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/distance/getDistanceBetweenTwoPoints.php")!
           
       }
    
    func urlDistance()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/distance/checkDistance.php")!
           
       }
    
    private enum CodingKeys: String, CodingKey {
                case message
                case distanceInMiles = "distance"
               
               
                
              
                
            }
    
    
    public  func getDistance(distanceInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
    {
     
        let url = self.url()
        let data_to_server=distanceInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        
      
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
            guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
                print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
               
                completion(success,error,response as? HTTPURLResponse)
                return
                
            }
           do
           {
            success = true
            let decoder = JSONDecoder()
            self.distance = try decoder.decode(Distance.self, from: data)
           }
            catch let err
            {
                errorMessage=err
               
            }
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,errorMessage,response as? HTTPURLResponse)
            }
            
            
        })
        dataTask?.resume()
        
    }
    
    public  func getMarket(addressInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
    {
     
        let url = self.urlDistance()
        let data_to_server=addressInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        
      
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
            guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
                print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
               
                completion(success,error,response as? HTTPURLResponse)
                return
                
            }
           do
           {
            success = true
            let decoder = JSONDecoder()
               self.market = try decoder.decode(Market.self, from: data)
           }
            catch let err
            {
                errorMessage=err
               
            }
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,errorMessage,response as? HTTPURLResponse)
            }
            
            
        })
        dataTask?.resume()
        
    }

    
}
