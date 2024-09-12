//
//  CustomerOrder.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/21/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class CustomerOrder:Decodable {
    
    var order:Order?
    var seller:Seller?
    var courier:Courier?
    var address:Address?
    
    private enum CodingKeys: String, CodingKey {
        case order
        case seller
        case courier
        case address
    }
    
    
    typealias SearchCompleteWithError = (Bool,Error?) -> Void
    fileprivate var dataTask: URLSessionDataTask? = nil
    
     var customerOrders=[CustomerOrder]()
    var customerInfoDict=[String:Any]()
    
    func url()->URL
       {
          
           return URL(string:"https://www.htsdelivery.com/api/order/customerOrders.php")!
           
       }
    public  func getCustomerOrders(customerId:Int,completion:@escaping SearchCompleteWithError)
    {
     
        let url = self.url()
        customerInfoDict["customer_id"]=customerId;
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
              let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
              let customerInfo = st! as String
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
            print((response as? HTTPURLResponse)?.statusCode)
              completion(success,error)
                return
                
            }
            do
            {
                success = true
                let decoder = JSONDecoder()
                self.customerOrders = try decoder.decode([CustomerOrder].self, from: data)
            }
            catch let err
            {
                print("Err customer orders", err)
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
