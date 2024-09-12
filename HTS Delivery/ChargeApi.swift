//
//  ChargeApi.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 9/30/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class ChargeApi {
    
    
    static public func processPayment(_ orderInfo: [String:Any], completion: @escaping (String?, String?) -> Void) {
        let url = URL(string: "https://www.htsdelivery.com/api/order/processPayment.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let httpBody = try? JSONSerialization.data(withJSONObject: orderInfo)
       // request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as NSError?{
                if error.domain == NSURLErrorDomain {
                    DispatchQueue.main.async {
                        completion("", "Could not contact host")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("", "Something went wrong")
                    }
                }
            } else if let data = data {
                if let httpResponse = response as? HTTPURLResponse  {
                    
                    print("Error code \(httpResponse.statusCode)")
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                        DispatchQueue.main.async {
                            completion("success", nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("", json["message"] as? String)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("", "Failure")
                    }
                }
                
                
            }
        }.resume()
    }
}
