//
//  OrderInfo.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/1/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation

class OrderInfo:NSObject,NSCoding {
    
    
    var deliveryInstructions:String
    var orderType:Int
    var address:Address?
    static var defaults=UserDefaults.standard
    
    init(deliveryInstructions:String,orderType:Int,address:Address?) {
        self.deliveryInstructions=deliveryInstructions
        self.orderType=orderType
        self.address=address
    }
    required  init?(coder: NSCoder) {
        self.deliveryInstructions = coder.decodeObject(forKey: "delivery_instructions") as! String
        self.orderType = Int(coder.decodeInt32(forKey: "order_type"))
        self.address = coder.decodeObject(forKey: "address") as? Address
    
        
       }
    
    func encode(with coder: NSCoder) {
        coder.encode(deliveryInstructions, forKey: "delivery_instructions")
        coder.encode(orderType, forKey:"order_type" )
        coder.encode(address, forKey: "address")
    }
    static func updateOrderInfo(orderInfo:OrderInfo) -> Void {
        let encodedData=NSKeyedArchiver.archivedData(withRootObject: orderInfo)
            defaults.set(encodedData, forKey: "orderInfo")
            defaults.synchronize()
        }
    
     static func getOrderInfo() -> OrderInfo? {
        var orderInfo:OrderInfo?
        if let decodedOrderInfo = defaults.object(forKey: "orderInfo") as? Data
        {
            orderInfo = NSKeyedUnarchiver.unarchiveObject(with: decodedOrderInfo) as? OrderInfo
        }
        
        return orderInfo
    }
}
