//
//  Customer.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 3/30/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Customer: NSObject,NSCoding,Codable,NSSecureCoding {
    static var supportsSecureCoding:Bool=true
    
    
    var customerId:Int
    var firstName:String
    var lastName:String
    var email:String
    var phone:String
    var zipCode:String
    var password:String
    
    private enum CodingKeys: String, CodingKey {
             case customerId = "id"
             case firstName = "first_name"
             case lastName = "last_name"
             case email
             case phone
             case password
             case zipCode = "zip_code"
            
             
           
             
         }
       
    
    fileprivate var dataTask: URLSessionDataTask? = nil
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    typealias SearchCompleteWithErrorAndStatus = (Bool,Error?,HTTPURLResponse?) -> Void
    typealias SearchCompleteWithMessage = (Bool,Error?,String) -> Void
    var customer:Customer?
    static var defaults=UserDefaults.standard
    
    func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/customer/getCustomerByEmail.php")!
           
       }
    func urlCustomerById()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/customer/getCustomerById.php")!
        
    }
    func urlCreate()->URL
          {
             
              return URL(string:"https://www.htsdelivery.com/api/customer/createCustomer.php")!
              
          }
    func urlUpdate()->URL
             {
                
                 return URL(string:"https://www.htsdelivery.com/api/customer/updateCustomer.php")!
                 
             }
    func urlRequest() -> URL {
        return URL(string:"https://www.htsdelivery.com/api/password_reset_request/reset-request.php")!
    }
  
       
    
    @objc init(customerId:Int,firstName:String,lastName:String,email:String,phone:String,zipCode:String,password:String)
   {
    
            
          self.customerId = customerId
          self.firstName = firstName
          self.lastName = lastName
          self.email = email
          self.phone = phone
          self.zipCode = zipCode
          self.password=password
          
          super.init()
    
          
    }
      required convenience init?(coder aDecoder: NSCoder) {
         let customerId = aDecoder.decodeInt32(forKey: "customer_id") 
          let firstName = aDecoder.decodeObject(forKey: "first_name") as! String
          let lastName = aDecoder.decodeObject(forKey: "last_name") as! String
          let email = aDecoder.decodeObject(forKey: "email") as! String
          let phone = aDecoder.decodeObject(forKey: "phone") as! String
          let zipCode = aDecoder.decodeObject(forKey: "zip_code") as! String
          let password = aDecoder.decodeObject(forKey: "password") as! String
         self.init(customerId: Int(customerId), firstName: firstName, lastName: lastName, email: email, phone: phone, zipCode: zipCode,password:password)
          
      }
      func encode(with aCoder: NSCoder) {
          aCoder.encode(customerId, forKey: "customer_id")
          aCoder.encode(firstName, forKey: "first_name")
          aCoder.encode(lastName, forKey: "last_name")
          aCoder.encode(email, forKey: "email")
          aCoder.encode(phone, forKey: "phone")
          aCoder.encode(zipCode, forKey: "zip_code")
          aCoder.encode(password, forKey: "password")
          
          
          
      }
    
    public  func getCustomer(customerInfo:String,completion:@escaping SearchCompleteWithError)
       {
        
           let url = self.url()
           let data_to_server=customerInfo
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
                   self.customer = try decoder.decode(Customer.self, from: data)
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
    public  func getCustomerById(customerId:String,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.urlCustomerById()
        let data_to_server="customer_id=\(customerId)"
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
                self.customer = try decoder.decode(Customer.self, from: data)
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
    
    public  func createCustomer(customerInfo:String,completion:@escaping SearchCompleteWithMessage)
    {
     
        let url = self.urlCreate()
        let data_to_server=customerInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
            guard let data = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 201 else {
                print("Big error \( (response as? HTTPURLResponse)?.statusCode)")
               
                
                do
                {
               
                    let decoder = JSONDecoder()
                    let messageDict = try decoder.decode([String:String].self, from: data!)
                if let message = messageDict["message"]
                    {
                    completion(success,error,message)
                }
                }
                catch let err
                {
                    print("Err", err)
                   
                }
               
              
                return
                
            }
           
           
            
            do
            {
                success = true
                let decoder = JSONDecoder()
                let messageDict = try decoder.decode([String:String].self, from: data)
            if let message = messageDict["message"]
                {
                completion(success,error,message)
                DispatchQueue.main.async
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        completion(success,error,message)
                }
            }
               
                
            }
            catch let err
            {
                print("Err", err)
               
            }
           
            
          
           
            
        })
        dataTask?.resume()
        
    }
    public  func requestPasswordReset(customerInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
       {
        
        let url = self.urlRequest()
           let data_to_server=customerInfo
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
    public  func updateCustomer(customerInfo:String,completion:@escaping SearchCompleteWithErrorAndStatus)
       {
        
        let url = self.urlUpdate()
           let data_to_server=customerInfo
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
    
    
    static func saveCustomer(customer:Customer) -> Void {
        let encodedData:Data = try! NSKeyedArchiver.archivedData(withRootObject: customer, requiringSecureCoding: true)
    self.defaults.set(encodedData, forKey: "customerInfo")
    self.defaults.set(true, forKey: "isUserLoggedIn")
    self.defaults.synchronize()
        
    }
    static func saveCustomerStatus(status:Bool) -> Void {
       self.defaults.set(status, forKey: "isUserLoggedIn")
       self.defaults.synchronize()
           
       }
    static  func retrieveCustomerStatus() -> Bool {
        let status = defaults.bool(forKey: "isUserLoggedIn")
        return status
           
       }
       
       
    
  static  func retrieveCustomer() -> Customer? {
    var customer:Customer?
   if let decodedCustomer = defaults.object(forKey: "customerInfo") as? Data
   {
       customer = NSKeyedUnarchiver.unarchiveObject(with: decodedCustomer) as? Customer
   }
    
    return customer
        
    }
    
    
}
