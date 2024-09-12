//
//  AddressViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/31/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import GooglePlaces

class AddressViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    var titleText:String?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var navBarController:UINavigationController?
    var type:String?
    var rawData:Data?
    var info=[String:Any]()
    var myString:String?
    var address=Address(id: "", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: "")
    var userInformationDelegate:UserInformationDelegate?
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsViewController = GMSAutocompleteResultsViewController()
           resultsViewController?.delegate = self
        if let titleText = titleText {
            titleLabel.text=titleText
        }
           if(searchController == nil)
           {
           searchController = UISearchController(searchResultsController: resultsViewController)
           }
           searchController?.searchResultsUpdater = resultsViewController
           searchController?.searchBar.layer.cornerRadius=5
           searchController?.searchBar.clipsToBounds=true
           searchController?.isActive=true
           searchBar.addSubview((searchController?.searchBar)!)
           searchController?.searchBar.placeholder="Enter address"
           searchController?.hidesNavigationBarDuringPresentation = false
           definesPresentationContext = true
        // Do any additional setup after loading the view.
    }
    
    func displayMessage(message:String,title:String)
        
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
// Handle the user's selection.
extension AddressViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        info["address_to_check"]=place.formattedAddress
        if JSONSerialization.isValidJSONObject(self.info) { // True
            do {
                self.rawData = try JSONSerialization.data(withJSONObject: self.info, options: .init(rawValue: String.Encoding.utf8.rawValue))
                let st = NSString(data: self.rawData!, encoding: String.Encoding.utf8.rawValue)
                myString = st as! String
                print(myString)
            } catch {
                print("Problem")
            }
        }
        address.checkDistance(addressToCheck: myString!, completion: { [self]
            success,error in
            if success
            {
               
                if let type=type,type=="delivery"
                  {
                    navBarController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryNavBar") as? UINavigationController)
                    if let deliveryTableViewController=navBarController?.viewControllers.first as? DeliveryTableViewController
                    {
                        deliveryTableViewController.formattedAddress=place.formattedAddress
                        deliveryTableViewController.delegate=userInformationDelegate
                        deliveryTableViewController.market=address.market
                    }
                    
                   
                    dismiss(animated: true, completion: {
                       
                            
                        if let topMostViewController = getTopMostViewController()
                        {
                        topMostViewController.present(self.navBarController!, animated: true, completion: nil)
                        }
                       
                        
                    })
                    
                   
                         
                   
                        
                     
                   
                    
                }
                  else
                  {
                      navBarController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickupNavBar") as? UINavigationController)
                      if let pickupTableViewController=navBarController?.viewControllers.first as? PickupTableViewController
                      {
                          pickupTableViewController.formattedAddress=place.formattedAddress
                          pickupTableViewController.delegate=self.userInformationDelegate
                          pickupTableViewController.market=address.market
                      }
                      dismiss(animated: true, completion: {
                         
                              
                          if let topMostViewController = getTopMostViewController()
                          {
                              
                          topMostViewController.present(self.navBarController!, animated: true, completion: nil)
                          }
                         
                          
                      })
                        
                          
                       
                      
                  }
                
            }
            else
            {
                DispatchQueue.main.async {
                    displayMessage(message: "Your address is not in our delivery range", title: "Error")
                }
               
              
                
            }
        })
      

                                  
                  
       
        
            
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

func getTopMostViewController() -> UIViewController? {
   
    var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

           while let presentedViewController = topMostViewController?.presentedViewController {
               topMostViewController = presentedViewController
           }

           return topMostViewController
       }

