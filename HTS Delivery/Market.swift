//
//  Market.swift

//
//  Created by Moussa Dembele on 12/3/21.
//  Copyright © 2021 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Market:NSObject, Codable
{
    
var marketName:String?;
var marketId:String?;
var cityName:String?
var country:String?;
var currency:String?;
var tax:String? ;
var symbol:String?;
var symbolPosition:String?;
var basePay:String?

fileprivate var dataTask: URLSessionDataTask? = nil
typealias SearchCompleteWithError = (Bool,Error?) -> Void
    var market:Market?
    
    func url()->URL
    {
       
        return URL(string:"https://www.htsdelivery.com/api/market/readMarket.php")!
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case marketName = "market"
        case marketId = "id"
        case cityName = "city"
        case country
        case currency
        case tax
        case symbol
        case symbolPosition="symbol_position"
        case basePay="base_pay"
        
    }
   
    
    public  func getMarket(marketId:String,completion:@escaping SearchCompleteWithError)
    {
        var marketInfo=[String:Any]()
        marketInfo["market_id"]=marketId;
        var rawData: Data?
        var myString=""
        if JSONSerialization.isValidJSONObject(marketInfo) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: marketInfo, options: .init(rawValue: String.Encoding.utf8.rawValue))
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
             print((response as? HTTPURLResponse)?.statusCode)
            print("Big error in get market")
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
    
    }
    

