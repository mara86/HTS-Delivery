//
//  Seller.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 3/25/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Seller:NSObject,NSCoding,Codable,NSSecureCoding
{
    static var supportsSecureCoding: Bool  = true
    
    
    
    class Records: Codable {
        var records=[Seller]()
    }

    var id:String?
    var name:String?
    var email:String?
    var phone:String?
    var profileId:String?
    var sellerDescription:String?
    var address:String?
    var longitude:String?
    var latitude:String?
    var token:String?
    var pickupInstructions:String?
    var image:String?
    var logo:String?
    var deliveryFee:Double?
    var marketId:String?
    
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    var sellers=[Seller]()
    var market:Market?
    static var defaults=UserDefaults.standard
    
    var records:Records?
    
    func url()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/seller/showSellers.php")!
        
    }
    
    func urlSellersByMarket()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/seller/getSellersByMarket.php")!
        
    }
     
    
    private enum CodingKeys: String, CodingKey {
          case id
          case name
          case email
          case phone
          case profileId = "profile_id"
          case sellerDescription="description"
          case address
          case longitude
          case latitude
          case token
          case image
          case logo
          case pickupInstructions = "pickup_instructions"
          case deliveryFee="delivery_fee"
          case marketId="market_id"
          
        
          
      }
    init(id:String?,name:String?,email:String?,phone:String?,profileId:String?,sellerDescription:String?,address:String,latitude:String?,longitude:String?,token:String?,image:String?,pickupInstructions:String?,deliveryFee:Double?,marketId:String?,logo:String?) {
        
        self.id=id
        self.name=name
        self.email=email
        self.phone=phone
        self.profileId=profileId
        self.sellerDescription=sellerDescription
        self.address=address
        self.latitude=latitude
        self.longitude=longitude
        self.token=token
        self.image=image
        self.pickupInstructions=pickupInstructions
        self.deliveryFee=deliveryFee
        self.marketId=marketId
        self.logo=logo
    }
    func encode(with coder: NSCoder) {
                coder.encode(id, forKey: "seller_id")
                coder.encode(name, forKey: "name")
                coder.encode(email, forKey: "email")
                coder.encode(phone, forKey: "phone")
                coder.encode(profileId, forKey: "profile_id")
                coder.encode(sellerDescription, forKey: "seller_description")
                coder.encode(address, forKey: "address")
                coder.encode(longitude, forKey: "longitude")
                coder.encode(latitude, forKey: "latitude")
                coder.encode(token, forKey: "token")
                coder.encode(image, forKey: "image")
                coder.encode(pickupInstructions, forKey: "pickup_instructions")
                coder.encode(deliveryFee, forKey: "delivery_fee")
                coder.encode(marketId, forKey: "market_id")
                coder.encode(logo, forKey: "logo")
    }
    
    required init?(coder: NSCoder) {
         id = coder.decodeObject(forKey: "seller_id") as? String
         name = coder.decodeObject(forKey: "name") as? String
         email = coder.decodeObject(forKey: "email") as? String
         phone = coder.decodeObject(forKey: "phone") as? String
         profileId = coder.decodeObject(forKey: "profile_id") as? String
         sellerDescription = coder.decodeObject(forKey: "seller_description") as? String
         address = coder.decodeObject(forKey: "address") as? String
         longitude = coder.decodeObject(forKey: "longitude") as? String
         latitude = coder.decodeObject(forKey: "email") as? String
         token = coder.decodeObject(forKey: "token") as? String
         image = coder.decodeObject(forKey: "image") as? String
         pickupInstructions = coder.decodeObject(forKey: "pickup_instructions") as? String
         deliveryFee=coder.decodeObject(forKey: "delivery_fee") as? Double
         marketId=coder.decodeObject(forKey: "market_id") as? String
         logo=coder.decodeObject(forKey: "logo") as? String
    }
    
    public func showSellers(completion:@escaping SearchCompleteWithError)
       {
        let url = self.url()
           var request = URLRequest(url: url)
           request.httpMethod="POST"
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
                self.records = try decoder.decode(Records.self, from: data)
                if let record=self.records
                {
                    self.sellers = record.records
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
    
    public func getSellersByMarket(marketInfo:String, completion:@escaping SearchCompleteWithError)
       {
           let url = self.urlSellersByMarket()
           var request = URLRequest(url: url)
           let data_to_server=marketInfo
           request.httpBody=data_to_server.data(using: String.Encoding.utf8)
           request.httpMethod="POST"
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
                self.records = try decoder.decode(Records.self, from: data)
                if let record=self.records
                {
                    self.sellers = record.records
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
    
    static func saveSeller(seller:Seller) -> Void {
        let encodedData:Data = try! NSKeyedArchiver.archivedData(withRootObject: seller, requiringSecureCoding: true)
        self.defaults.set(encodedData, forKey: "sellerInfo")
        self.defaults.synchronize()
          
      }
      
    static  func retrieveSeller() -> Seller? {
      var seller:Seller?
      
     if let decodedSeller = defaults.object(forKey: "sellerInfo") as? Data
     {
         seller = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Seller.self, from: decodedSeller)
     }
      
      return seller
          
      }
    
    
    
    
    
}
