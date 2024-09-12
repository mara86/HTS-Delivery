//
//  Order.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/21/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Order: Decodable {
    
    var orderNumber=""
    var orderDate=""
    var orderTotal=""
    var transactionId:String?
    var status=""
    var courierId:String?
    var customerId=""
    var restStatus=""
    var amountEarned=""
    var orderDatewt=""
    var orderTime=""
    var updatedWaitTime=""
    var tip=""
    var deliveryInstructions=""
    
   
    
    private enum CodingKeys: String, CodingKey {
                case status
                case tip
                case orderNumber = "order_number"
                case orderDate = "order_date"
                case orderTotal = "order_total"
                case transactionId="transaction_id"
                case courierId="courier_id"
                case customerId = "customer_id"
                case restStatus = "rest_status"
                case amountEarned = "amount_earned"
                case orderDatewt = "order_date_wt"
                case orderTime = "order_time"
                case updatedWaitTime = "updated_wait_time"
                case deliveryInstructions = "delivery_instructions"
               
                
              
                
            }
    
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    fileprivate var dataTask: URLSessionDataTask? = nil
    var transactionInfoDict=[String:Any]()
    var defaults = UserDefaults.standard
    let urlPaydunya = "https://www.htsdelivery.com/api/order/placeOrderPaydunya.php"
    let urlCash = "https://www.htsdelivery.com/api/order/placeOrderCash.php"
    
    var invoiceUrl:URL?
    
    func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/order/getOrderByTransactionId.php")!
           
       }
    
    
    public  func getOrderByTransactionId(transactionId:String,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.url()
        transactionInfoDict["transaction_id"]=transactionId;
        let toServer = try! JSONSerialization.data(withJSONObject: transactionInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
              let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
              let transactionInfo = st! as String
        let data_to_server=transactionInfo
        var request = URLRequest(url: url)
        request.httpMethod="POST"
    
        request.httpBody=data_to_server.data(using: String.Encoding.utf8)
        dataTask=URLSession.shared.dataTask(with: request, completionHandler: {data, response
            , error in
            var success = false
           
         guard let _ = data , let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
            print("Big error")
            print((response as? HTTPURLResponse)?.statusCode)
              completion(success,error)
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
    
    
    func placeOrderPaydunya(subTotal:Double,tipValue:Double,deliveryFee:Double,tax:Double,completion:@escaping SearchCompleteWithError) {
        
        var cartDictionary=[String:Any]()
        var decodedCartItems = [Product]()
        var rawData:Data?
        var myString:String?
        
        if let seller=Seller.retrieveSeller() {
            var s=[String:Any]()
            s["id"]=seller.id
            s["phone"]=seller.phone
            s["name"]=seller.name
            s["address"]=seller.address
            s["delivery_fee"]=seller.deliveryFee
            s["market_id"]=seller.marketId
            
            cartDictionary["seller"]=s;
        }
        else
        {
            print("Seller is nil")
            return
        }
        if let customer = Customer.retrieveCustomer()
        {
            var c=[String:Any]()
            c["email"]=customer.email
            cartDictionary["customer_id"]=customer.customerId
            cartDictionary["customer"]=c
            
        }
        else
        {
            return
        }
        if  let orderInfo = OrderInfo.getOrderInfo(),orderInfo.orderType==1
        {
            cartDictionary["order_type"]=1
            cartDictionary["delivery_instructions"]=orderInfo.deliveryInstructions
            cartDictionary["address_id"]=orderInfo.address!.id
            cartDictionary["address"]=orderInfo.address!.completeAddress
        }
        else
        {
        cartDictionary["order_type"]=0
        cartDictionary["delivery_instructions"]=nil
        cartDictionary["address_id"]=nil
        }
        cartDictionary["tip"]="\(round(tipValue*100)/100)"
        var items=[Any]()
       
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            for decodedItem in decodedCartItems {
                var item=[String:Any]()
                 var subs=[Any]()
                var extras=[Any]()
                item["id"]=decodedItem.itemId
                item["name"]=decodedItem.designation
                item["price"]=decodedItem.price
                for ps in decodedItem.productSubCategories {
                    var sub=[String:Any]()
                    sub["id"]=ps.id
                    sub["price"]=ps.price
                    sub["name"]=ps.name
                    subs.append(sub)
                }
                for  ext in decodedItem.productExtras {
                    var extra=[String:Any]()
                    extra["id"]=ext.id
                    extra["price"]=ext.price
                    extra["name"]=ext.name
                    extras.append(extra)
                }
                item["item_sub_categories"]=subs
                item["item_extras"]=extras
                item["quantity"]=decodedItem.quantity
                items.append(item)
            }
            //Replace tax with city Tax
            cartDictionary["order_total"]="\(round((subTotal+tax+tipValue+deliveryFee)*100)/100)"
            cartDictionary["items"]=items
            print(cartDictionary)
            
            if JSONSerialization.isValidJSONObject(cartDictionary) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: cartDictionary, options: .init(rawValue: String.Encoding.utf8.rawValue))
                    let st = NSString(data: rawData!, encoding: String.Encoding.utf8.rawValue)
                    myString = st as! String
                    print(myString)
                } catch {
                    print("Problem")
                }
            }
            
        }
        // Update URL with your server
        let paymentURL = URL(string: urlPaydunya)!
        var request = URLRequest(url: paymentURL)
        let products=myString!
        let data_to_server=products
        request.httpBody = data_to_server.data(using: String.Encoding.utf8);
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil)
            {
                print(error ?? "error");
                completion(false, error)
                
                
            }
            else
            {
    if let data=data, let httpResponse=response as? HTTPURLResponse,httpResponse.statusCode==201
            {
        
       
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
            
        
             
            completion(true, error)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
            let fromServer = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                let fromServerString = fromServer as String?
                print(fromServerString!)
            }
                else
                {
                 let httpResponse = response as? HTTPURLResponse
                    
                    print(httpResponse?.statusCode)
                    
                }
                }
            // TODO: Handle success or failure
            }.resume()
    }
    
    
    func placeOrderCash(subTotal:Double,tipValue:Double,deliveryFee:Double,tax:Double,completion:@escaping SearchCompleteWithError) {
        
        var cartDictionary=[String:Any]()
        var decodedCartItems = [Product]()
        var rawData:Data?
        var myString:String?
        
        if let seller=Seller.retrieveSeller() {
            var s=[String:Any]()
            s["id"]=seller.id
            s["phone"]=seller.phone
            s["name"]=seller.name
            s["address"]=seller.address
            s["delivery_fee"]=seller.deliveryFee
            s["market_id"]=seller.marketId
            
            cartDictionary["seller"]=s;
        }
        else
        {
            print("Seller is nil")
            return
        }
        if let customer = Customer.retrieveCustomer()
        {
            var c=[String:Any]()
            c["email"]=customer.email
            cartDictionary["customer_id"]=customer.customerId
            cartDictionary["customer"]=c
            
        }
        else
        {
            return
        }
        if  let orderInfo = OrderInfo.getOrderInfo(),orderInfo.orderType==1
        {
            cartDictionary["order_type"]=1
            cartDictionary["delivery_instructions"]=orderInfo.deliveryInstructions
            cartDictionary["address_id"]=orderInfo.address!.id
            cartDictionary["address"]=orderInfo.address!.completeAddress
        }
        else
        {
        cartDictionary["order_type"]=0
        cartDictionary["delivery_instructions"]=nil
        cartDictionary["address_id"]=nil
        }
        cartDictionary["tip"]="\(round(tipValue*100)/100)"
        var items=[Any]()
       
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            for decodedItem in decodedCartItems {
                var item=[String:Any]()
                 var subs=[Any]()
                var extras=[Any]()
                item["id"]=decodedItem.itemId
                item["name"]=decodedItem.designation
                item["price"]=decodedItem.price
                item["item_instruction"]=decodedItem.itemInstructions
                for ps in decodedItem.productSubCategories {
                    var sub=[String:Any]()
                    sub["id"]=ps.id
                    sub["price"]=ps.price
                    sub["name"]=ps.name
                    subs.append(sub)
                }
                for  ext in decodedItem.productExtras {
                    var extra=[String:Any]()
                    extra["id"]=ext.id
                    extra["price"]=ext.price
                    extra["name"]=ext.name
                    extras.append(extra)
                }
                item["item_sub_categories"]=subs
                item["item_extras"]=extras
                item["quantity"]=decodedItem.quantity
                items.append(item)
            }
            //Replace tax with city Tax
            cartDictionary["order_total"]="\(round((subTotal+tax+tipValue+deliveryFee)*100)/100)"
            cartDictionary["items"]=items
            print(cartDictionary)
            
            if JSONSerialization.isValidJSONObject(cartDictionary) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: cartDictionary, options: .init(rawValue: String.Encoding.utf8.rawValue))
                    let st = NSString(data: rawData!, encoding: String.Encoding.utf8.rawValue)
                    myString = st as! String
                    print(myString)
                } catch {
                    print("Problem")
                }
            }
            
        }
        // Update URL with your server
        let paymentURL = URL(string: urlCash)!
        var request = URLRequest(url: paymentURL)
        let products=myString!
        let data_to_server=products
        request.httpBody = data_to_server.data(using: String.Encoding.utf8);
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil)
            {
                print(error ?? "error");
                completion(false, error)
                
                
            }
            else
            {
    if let data=data, let httpResponse=response as? HTTPURLResponse,httpResponse.statusCode==201
            {
             
            completion(true, error)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
            let fromServer = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                let fromServerString = fromServer as String?
                print(fromServerString!)
            }
                else
                {
                 let httpResponse = response as? HTTPURLResponse
                  completion(false,error)
                    print(httpResponse?.statusCode)
                    
                }
                }
            // TODO: Handle success or failure
            }.resume()
    }
}
    
