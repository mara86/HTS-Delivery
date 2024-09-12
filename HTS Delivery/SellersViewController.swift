//
//  SellersViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 3/23/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class SellersViewController: UIViewController, AddressSelectionDelegate {
   
    
    var titleLabel:UILabel?
    var defaults=UserDefaults.standard
    var seller=Seller(id: "", name: "", email: "", phone: "", profileId: "", sellerDescription: "", address: "", latitude: "", longitude: "", token: "", image: "", pickupInstructions: "", deliveryFee: nil,marketId: "",logo: "")
    var shared=Shared()
    var addresses=[Address]()
    var decodedCustomer:Customer?
    var market=Market()
    let loadingView = UIView()
    let activityIndicator=UIActivityIndicatorView()
    var address=Address(id: "", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: "")
    var distance = Distance()
    var customerAddress="3600 Market Street, Philadelphia Pa 19104"
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        shared.showLoadingView(view: view)
        tableView.delegate=self
        tableView.dataSource=self
        tableView.estimatedRowHeight=400
        tableView.rowHeight=UITableView.automaticDimension
        setAddress()
        checkDistance()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        setAddress()
       // checkDistance()
    }
    
    func setAddress() -> Void {
        if let orderInfo = OrderInfo.getOrderInfo() {
            if orderInfo.orderType==1 && orderInfo.address != nil
            {
            customerAddress = orderInfo.address!.completeAddress
            }
            else if orderInfo.orderType==0, let seller=Seller.retrieveSeller(),let address=seller.address
            {
            customerAddress = address
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
    
    @objc func load(marketId:Int) -> Void {
       var marketInfoDict=[String:Any]()
       marketInfoDict["market_id"]=marketId
       let toServer = try! JSONSerialization.data(withJSONObject: marketInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
             let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
             let marketInfo = st! as String
        
        
       seller.getSellersByMarket(marketInfo: marketInfo, completion: { success,error in
              if(success)
              {
                  DispatchQueue.main.async {
                      self.shared.hideReloadingView()
                      self.shared.hideLoadingView()
                      self.tableView.reloadData()
                  }
              }
              if let error = error
              {
                  DispatchQueue.main.async {
                     self.shared.hideLoadingView()
                     let button = self.shared.showReloadingView(view: self.view)
                      button.addTarget(self, action: #selector(self.checkDistance), for: UIControl.Event.touchUpInside)
                  }
                  
                  print(error.localizedDescription)
                  
              }
              })
    }
    
    @objc func checkDistance() -> Void {
       
        var addressInfoDict=[String:Any]()
        addressInfoDict["address_to_check"]=customerAddress
        let toServer = try! JSONSerialization.data(withJSONObject: addressInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
              let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
              let addressInfo = st! as String
        distance.getMarket(addressInfo: addressInfo, completion: { [self]
            success,error, httpResponse in
            
            if success
            {
                if let market = self.distance.market
                {
                    let address=Address(id: "", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: self.customerAddress)
                    Address.saveAddress(address: address)
                
                    DispatchQueue.main.async { [self] in
                        
                        self.load(marketId: Int(market.marketId!)!)
                        shared.loadViewController(viewController: self, width: view.frame.width)
                    }
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
            else
            {
               
                    DispatchQueue.main.async {
                        self.shared.hideLoadingView()
                       let button = self.shared.showReloadingView(view: self.view)
                        
                        button.addTarget(self, action: #selector(SellersViewController.self.checkDistance), for: UIControl.Event.touchUpInside)
                    }
                    
                    
             
                
            }
                    
        })
    }
    func wasAddressSelected(address: String) {
        customerAddress=address
        checkDistance()
       
       
    }
    
    
}

extension SellersViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seller.sellers.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        headerView.text="\(seller.sellers.count) Merchants"
        headerView.backgroundColor=UIColor.white
       
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionTitle="   5 Restaurants"
        
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sellerCell = tableView.dequeueReusableCell(withIdentifier: "SellerCell") as! SellerTableViewCell
        let seller = self.seller.sellers[indexPath.row]
        if let name = seller.name
        {
        sellerCell.sellerName.text=String(htmlEncodedString: name)
        }
        if let description = seller.sellerDescription
        {
        sellerCell.cuisineType.text=String(htmlEncodedString: description)
        }
        if let address = seller.address
        {
        sellerCell.details.text=String(htmlEncodedString: address) 
        }
        if let image = seller.image
        {
        if let imageUrl = URL(string: image)
        {
            sellerCell.sellerImageView.loadImageWithURL(imageUrl)
            
        }
        }
        
        if let logo = seller.logo
        {
        if let logoUrl = URL(string: logo)
        {
           
            sellerCell.logoImageView.loadImageWithURL(logoUrl)
        }
        }
       
        return sellerCell
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    if let productsCollectionViewController = segue.destination as? ProductsCollectionViewController
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                productsCollectionViewController.seller=seller.sellers[indexPath.row]
               
            }
            
        
        
        }
        
    
    }
    
    
    
   
    
}
extension SellersViewController:UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString.string)
    }
}

