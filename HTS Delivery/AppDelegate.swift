//
//  AppDelegate.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 11/22/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import Foundation
import GooglePlaces
import GoogleMaps
import Firebase
import SquareInAppPaymentsSDK

let themeColor = UIColor(red: 255/255, green: 165/255, blue: 0, alpha: 1.0)
let barColor =  UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    {
        didSet
        {
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let memoryCapacity = 500*1024*1024;
        let diskCapacity = memoryCapacity
        window?.tintColor = themeColor
        UINavigationBar.appearance().barTintColor = barColor
        UITabBar().barTintColor = barColor
        //UINavigationBar.appearance().barStyle = .blackTranslucent
        //SandBox
        SQIPInAppPaymentsSDK.squareApplicationID="sandbox-sq0idb-vArcxMNEfzna39OLBisyBA"
        //Production
        //SQIPInAppPaymentsSDK.squareApplicationID="sq0idp-R5pGy0VPkeckTsy1rEzQpA"
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes=[.foregroundColor:UIColor.white]
            let appearanceTabBar = UITabBarAppearance()
            appearanceTabBar.configureWithDefaultBackground()
            appearanceTabBar.backgroundColor =  UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor =    UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
            UINavigationBar.appearance().scrollEdgeAppearance=appearance
            UINavigationBar.appearance().standardAppearance=appearance
            UITabBar.appearance().standardAppearance=appearanceTabBar
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance=appearanceTabBar
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        GMSPlacesClient.provideAPIKey("AIzaSyC32xYXOYgBhJFEKHTOgfjRwBsyy0-PvFA")
        GMSServices.provideAPIKey("AIzaSyC32xYXOYgBhJFEKHTOgfjRwBsyy0-PvFA")
        FirebaseApp.configure()
           

        
        return true
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getRootViewController() -> TabBarController {
        let tabBarController = window!.rootViewController
                   as! TabBarController
        return tabBarController
        
    }


}

