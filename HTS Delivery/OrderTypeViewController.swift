//
//  OrderTypeViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/2/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import GooglePlaces

protocol AddressSelectionDelegate
{
    func  wasAddressSelected(address:String)
    
}

class OrderTypeViewController: UIViewController {
    @IBOutlet weak var orderTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionsTextView: UITextView!
    var addresses=[String]()
    var addressSelectionDelegate:AddressSelectionDelegate?
    var defaults=UserDefaults.standard
    var addressesArray=[Address]()
    var distance = Distance()
    var customerInfoDict=[String:Any]()
    var orderInfo:OrderInfo?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var completeAddress:String?
    var indexPathOfSelectedRow:IndexPath?
    var orderType=0
    var shared=Shared()
    var address=Address(id: "", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: "")
    var customer:Customer?
    @IBAction func changeOrderType(_ sender: UISegmentedControl) {
        
       orderType=sender.selectedSegmentIndex
       if let indexPathOfSelectedRow=indexPathOfSelectedRow
       {
        print("Type \(orderType) \(instructionsTextView.text) \(addressesArray[indexPathOfSelectedRow.row].completeAddress)")
        }
    }
    
    
    @IBAction func addAddress(_ sender: Any) {
         if let indexPathOfSelectedRow=indexPathOfSelectedRow
         {
             if orderTypeSegmentedControl.selectedSegmentIndex==1
             {
                 var addressInfoDict=[String:Any]()
                 addressInfoDict["address_to_check"]=addressesArray[indexPathOfSelectedRow.row].completeAddress
                 let toServer = try! JSONSerialization.data(withJSONObject: addressInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
                       let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
                       let addressInfo = st! as String
                 distance.getMarket(addressInfo: addressInfo, completion: { [self]
                     success,error, httpResponse in
                     
                     if success
                     {
                         if let _ = self.distance.market
                         {
                             
                             
                         
                        orderType=1
                             
                        orderInfo=OrderInfo(deliveryInstructions: instructionsTextView.text, orderType: orderType, address: addressesArray[indexPathOfSelectedRow.row])
                        if let orderInfo=orderInfo {
                        OrderInfo.updateOrderInfo(orderInfo: orderInfo)
                       
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orderTypeUpdated"), object: nil)
                        }
                       
                        dismiss(animated: true, completion: nil)
                         }
                     }
                     else if let httpResponse = httpResponse,httpResponse.statusCode==404
                     {
                                 DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: "Out of range", message: "Sorry, your address is out of our delivery range", preferredStyle: .alert)
                                     let action = UIAlertAction(title: "OK", style: .default)
                                     alertController.addAction(action)
                                     self.present(alertController, animated: true)
                     }
                     }
                 
             })
            }
             else
             {
                 print("second")
                 orderType=0
                 orderInfo=OrderInfo(deliveryInstructions: instructionsTextView.text, orderType: orderType, address: nil)
                 if let orderInfo=orderInfo {
                 OrderInfo.updateOrderInfo(orderInfo: orderInfo)
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orderTypeUpdated"), object: nil)
                 dismiss(animated: true)
                 }
                 
             }
        }
        else if orderTypeSegmentedControl.selectedSegmentIndex==1
         {
            let alertController = UIAlertController(title: "Select address", message: "Please select a delivery address.", preferredStyle: .alert)
             let action = UIAlertAction(title: "OK", style: .default)
             alertController.addAction(action)
             self.present(alertController, animated: true)
        }
        else
        {
            print("last")
            orderInfo=OrderInfo(deliveryInstructions: instructionsTextView.text, orderType: orderType, address: nil)
            if let orderInfo=orderInfo {
            OrderInfo.updateOrderInfo(orderInfo: orderInfo)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orderTypeUpdated"), object: nil)
            dismiss(animated: true)
            }
            
        }
           
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        instructionsTextView.layer.borderWidth=1
        instructionsTextView.layer.borderColor=UIColor.black.withAlphaComponent(0.5).cgColor
        instructionsTextView.layer.cornerRadius=5
        resultsViewController = GMSAutocompleteResultsViewController()
           resultsViewController?.delegate = self
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
           orderInfo=OrderInfo.getOrderInfo()
            if let orderInfo = orderInfo
            {
            instructionsTextView.text=orderInfo.deliveryInstructions
                if orderInfo.orderType==1
                {
                    orderTypeSegmentedControl.selectedSegmentIndex=1
                }
                else
                {
                    orderTypeSegmentedControl.selectedSegmentIndex=0
                    
                }
            }
        
        if addressesArray.count==0 {
            loadAddresses()
        }
        
    }
    
  @objc  func loadAddresses() -> Void {
   /* shared.showLoadingView(view: view)
    if let customer = Customer.retrieveCustomer()
               {
        customerInfoDict["customer_id"]=customer.customerId
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
              let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
              let customerInfo = st! as String
                   address.getAddress(customerId:customerInfo, completion: {success,error in
                       
                       if(success)
                       {
                        
                           if self.address.addresses.count==0 {
                               print("No address")
                           }
                           else
                           {
                           self.addressesArray=self.address.addresses
                           DispatchQueue.main.async {
                               self.tableView.reloadData()
                           }
                           }
                        DispatchQueue.main.async {
                             self.shared.hideLoadingView()
                        }
                       
                          
                       }
                       else 
                       {
                        DispatchQueue.main.async {
                            self.shared.hideLoadingView()
                            let button = self.shared.showReloadingView(view: self.view)
                                                button.addTarget(self, action: #selector(self.loadAddresses), for: .touchUpInside)
                        }
                           
                       }
                  
                       
                       
                   })
               }*/
        
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

extension OrderTypeViewController:UITableViewDelegate
{
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let cellToChange = tableView.cellForRow(at: indexPathOfSelectedRow!)
        cellToChange?.accessoryType = .none
        indexPathOfSelectedRow=indexPath
        cell?.accessoryType = .checkmark

    }
    
}
extension OrderTypeViewController:UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell")
        if (indexPath.row==0)
        {
        indexPathOfSelectedRow=indexPath
        }
        let address=addressesArray[indexPath.row]
        cell?.textLabel?.text=address.completeAddress
        return cell!
        
    }
    
    
}

// Handle the user's selection.
extension OrderTypeViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
      
         completeAddress = place.formattedAddress
        if let completeAddress = completeAddress
        {
        addressSelectionDelegate?.wasAddressSelected(address: completeAddress)
        }
        if let completeAddress=completeAddress
                   {
                     /*  customerInfoDict["customer_id"]=customer.customerId
                       customerInfoDict["customer_address"]=completeAddress
                    let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
                    let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
                    let customerInfo = st! as String*/
                          
                    let address=Address(id: "0", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "0", apt: "", completeAddress: completeAddress)
                         print(address.id)
                        self.addressesArray.append(address)
                        self.tableView.reloadData()
                                  
                   }
        else if  let searchBar=searchController?.searchBar,let searchBarText=searchBar.text
                   {
            if !searchBarText.isEmpty
            {
                let address=Address(id: "0", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: searchBarText)
                addressesArray.append(address)
            }
                   }
        
            
        
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

