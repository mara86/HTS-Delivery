//
//  Address.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/5/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Address:NSObject,NSCoding,Codable
{
    
    var id:String
    var street:String
    var zipCode:String
    var city:String
    var state:String
    var latitude:String
    var longitude:String
    var customerId:String
    var apt:String
    var completeAddress:String
    
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    fileprivate var dataTask: URLSessionDataTask? = nil
    var addresses=[Address]()
    static var defaults=UserDefaults.standard
    var market:Market?
    func url()->URL
          {
             
              return URL(string:"https://www.htsdelivery.com/api/address/read_addresses.php")!
              
          }
    func urlCreate()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/address/create_address.php")!
        
    }
    
    func urlDistance()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/distance/checkDistance.php")!
        
    }
    
    
    private enum CodingKeys: String, CodingKey {
                case id
                case street
                case city
                case latitude
                case longitude
                case apt
                case state = "State"
                case zipCode = "zip_code"
                case customerId = "customer_id"
                case completeAddress = "complete_address"
               
               
                
              
                
            }
init(id:String,street:String,zipCode:String,city:String,state:String,latitude:String,longitude:String,customerId:String,apt:String,completeAddress:String)
    {
        self.id=id
        self.street=street
        self.zipCode=zipCode
        self.city=city
        self.state=state
        self.latitude=latitude
        self.longitude=longitude
        self.customerId=customerId
        self.apt=apt
        self.completeAddress=completeAddress
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.street = aDecoder.decodeObject(forKey: "street") as! String
        self.zipCode = aDecoder.decodeObject(forKey: "zip_code") as! String
        self.city = aDecoder.decodeObject(forKey: "city") as! String
        self.state = aDecoder.decodeObject(forKey: "state") as! String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as! String
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as! String
        self.customerId = aDecoder.decodeObject(forKey: "customer_id") as! String
        self.apt = aDecoder.decodeObject(forKey: "apt") as! String
        self.completeAddress = aDecoder.decodeObject(forKey: "complete_address") as! String
        
             
         }
         func encode(with aCoder: NSCoder) {
             aCoder.encode(id, forKey: "id")
             aCoder.encode(street, forKey: "street")
             aCoder.encode(zipCode, forKey: "zip_code")
             aCoder.encode(city, forKey: "city")
             aCoder.encode(state, forKey: "state")
             aCoder.encode(longitude, forKey: "longitude")
             aCoder.encode(latitude, forKey: "latitude")
             aCoder.encode(customerId, forKey: "customer_id")
             aCoder.encode(apt, forKey: "apt")
             aCoder.encode(completeAddress, forKey: "complete_address")
             
             
             
         }
    
    public  func checkDistance(addressToCheck:String,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.urlDistance()
        let data_to_server=addressToCheck
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
         guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
            print("Big error \((response as? HTTPURLResponse)?.statusCode)")
                errorMessage=error
              completion(success,errorMessage)
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
    
    public  func getAddress(customerId:String,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.url()
        let data_to_server=customerId
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            var errorMessage:Error?
         guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
            print("Big error \((response as? HTTPURLResponse)?.statusCode)")
              completion(success,error)
                return
                
            }
            do
            {
                success = true
                let decoder = JSONDecoder()
                self.addresses = try decoder.decode([Address].self, from: data)
            }
            catch let err
            {
                print("Err ", err)
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
    public  func createAddress(customerInfo:String,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.urlCreate()
        let data_to_server=customerInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            let d = data
         guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201
            else {
                print("Big error \(error?.localizedDescription)")
              completion(success,error)
            if let data = d
            {
            let st = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            let customerInfo = st! as String
                
                print(customerInfo)
            }
                return
                
            }
            success = true
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success,error)
            }
            
            
        })
        dataTask?.resume()
        
    }
    
    static func getDefaultAddress() -> Address? {
        var address:Address?
           
          if let decodedAddress = defaults.object(forKey: "defaultAddress") as? Data
          {
              address = NSKeyedUnarchiver.unarchiveObject(with: decodedAddress) as? Address
          }
           
           return address
               
           }
    
    static func saveAddress(address:Address) -> Void {
    let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: address)
    self.defaults.set(encodedData, forKey: "defaultAddress")
    self.defaults.synchronize()
    }
    
    }
    
    

