//
//  TabBarController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/26/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var cart:UITabBarItem?
    var defaults=UserDefaults.standard
    var decodedCartItems=[Product]()
    override func viewDidLoad() {
        super.viewDidLoad()
        cart = tabBar.items![2]
        setCartBadgeValue()
       
    // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if    let viewControllers = self.viewControllers, let navigationController=viewControllers[2] as? UINavigationController, let _=navigationController.viewControllers.first as? CartViewController
     {
        
        
       
     }
        
    }
    func setCartBadgeValue() -> Void {
        
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
                      {
                       var quantity=0
            decodedCartItems =  NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
                          for decodedItem in decodedCartItems
                          {
                           
                           quantity+=decodedItem.quantity
                          }
                       
                       if let cart=cart
                       {
                       cart.badgeValue="\(quantity)"
                       }
                         
                         
                      }
               
       
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
