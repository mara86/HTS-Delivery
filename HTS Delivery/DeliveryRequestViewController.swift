//
//  DeliveryRequestViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/25/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import SafariServices
import SquareInAppPaymentsSDK

class DeliveryRequestViewController: UIViewController,UITextFieldDelegate,UserInformationDelegate{
   
    
    var pickupInfo:DeliveryInfo?
    var dropOffInfo:DeliveryInfo?
    var distance=Distance()
    var info=[String:Any]()
    var rawData:Data?
    var deliveryInfo=DeliveryInfo()
    var shared=Shared()
    var customTipTextField:UITextField?
    var customTipValue=0.00
    var deliveryFee=0.00
    var tipValue=0.00
    var dInfo=[String:Any]()
    var pInfo=[String:Any]()
    var orderInfo=[String:Any]()
    var paymentInfo=[String:Any]()
    
    var card:Card?
    var paymentTypesViewController:PaymentTypesViewController?

    typealias SearchCompleteWithErrorAndStatus = (Bool,Error?,HTTPURLResponse?) -> Void
    

    

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    
    @IBOutlet weak var dropoffLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    
    @IBOutlet weak var requestDeliveryButton: UIButton!
    @IBOutlet weak var pickupStackView: UIStackView!
    
    @IBOutlet weak var deliveryStackView: UIStackView!
    @IBAction func requestDelivery(_ sender: Any) {
     
        if let dropOffInfo = dropOffInfo, let _=dropOffInfo.address {
            
            dInfo["first_name"]=dropOffInfo.firstName
            dInfo["last_name"]=dropOffInfo.lastName
            dInfo["telephone"]=dropOffInfo.telephone
            dInfo["address"]=dropOffInfo.address
            dInfo["apt"]=dropOffInfo.apt
            dInfo["customer_id"]=dropOffInfo.id
            orderInfo["delivery_instructions"]=dropOffInfo.instructions
           
        }
        else
        {
           displayMessage(message: "Please enter Delivery Information", title:"Error")
            return
        }
        if let pickupInfo = pickupInfo, let _=pickupInfo.address {
            pInfo["first_name"]=pickupInfo.firstName
            pInfo["last_name"]=pickupInfo.lastName
            pInfo["telephone"]=pickupInfo.telephone
            pInfo["address"]=pickupInfo.address
            pInfo["apt"]=pickupInfo.apt
            pInfo["customer_id"]=pickupInfo.id
            orderInfo["order_detail"]=pickupInfo.instructions
           
        }
        else
        {
            displayMessage(message: "Please enter Pickup Information", title:"Error")
            return
        }
        if let _ = dropOffInfo, let _=pickupInfo {
            requestDeliveryButton.titleLabel?.text="Continue $6"
            
        }
      
            customTip()
     
     
        
       
        
    }
     func showDelivery() {
        if let _ = Customer.retrieveCustomer(),Customer.retrieveCustomerStatus()
        {
        let viewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressViewController") as! AddressViewController)
            viewController.titleText="Delivery Address"
        viewController.type="delivery"
        viewController.userInformationDelegate=self
        present(viewController, animated: true)
        }else
        {
            showSign()
        }
    }
    func showPickup() {
        if let _ = Customer.retrieveCustomer(),Customer.retrieveCustomerStatus()
        {
        let viewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressViewController") as! AddressViewController)
            viewController.titleText="Pickup Address"
        viewController.type="pickup"
        viewController.userInformationDelegate=self
        present(viewController, animated: true)
        }
        else
        {
            showSign()
        }
    }
    
    func presentPaymentTypes()
    {
     
        paymentTypesViewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentTypesViewController") as! PaymentTypesViewController)
        
        paymentTypesViewController?.paymentTypesDelegate=self
        
        paymentTypesViewController?.paymentTypesViewController=paymentTypesViewController
        
        if let paymentTypesViewController = paymentTypesViewController
        {
            
            present(paymentTypesViewController, animated: true)
        }
      
   }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
       // delegate=self
       
        requestDeliveryButton.layer.cornerRadius=5
       
        // Do any additional setup after loading the view.
        
        
             
    }
    
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
      
      
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func wasUserInfoSaved(deliveryInfo: DeliveryInfo) {
        if deliveryInfo.type=="pickup" {
          
            pickupInfo=deliveryInfo
        }
        else
        {
            
            dropOffInfo=deliveryInfo
            
        }
        if let dropOff = dropOffInfo, let pickup=pickupInfo {
            calculateDeliveryFee(dropOffInfo: dropOff, pickupInfo: pickup, dist: { [self]
                distance in
                
                print("distance \(distance.distanceInMiles)")
                
                if let market = deliveryInfo.market, let basePay=market.basePay, let symbol=market.symbol, let symbolPoistion=market.symbolPosition
                {
                 orderInfo["market_id"]=market.marketId!
                    if distance.distanceInMiles<=3.00
                    {
                 deliveryFee=round(Double(basePay)!*2*100)/100
                    }
                    else
                    {
                        deliveryFee=round((Double(basePay)!*2+Double(basePay)!*(distance.distanceInMiles-3.00))*100)/100
                    }
                    if (Int(symbolPoistion)!==0)
                    {
                        DispatchQueue.main.async {
                            self.deliveryFeeLabel.text="\(symbol)\(self.deliveryFee)"
                        }
              
                    }
                    else
                    {
                        DispatchQueue.main.async { [self] in
                            deliveryFeeLabel.text="\(deliveryFee) \(symbol)"
                        }
                
                        
                    }
                    
                    
                }
                
            })
            
        }
        
        tableView.reloadData()
    }
    
    func showSign() -> Void {
        let viewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavigationController") as! UINavigationController)
        present(viewController, animated: true)
    }
    func displayMessage(message:String,title:String)
        
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func customTip() -> Void {
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            if let customTip=self.customTipTextField,let value = customTip.text
            {
                if let doubleValue = Double(value), doubleValue>=0
                {
                self.tipValue=doubleValue
                self.customTipValue=doubleValue
                self.orderInfo["tip"]=self.customTipValue
                }
                else
                {
                self.orderInfo["tip"]=self.customTipValue
                }
            }
            if let pickupInfo = self.pickupInfo,let dropOffInfo=self.dropOffInfo,let pickupMarket=pickupInfo.market,let dropOffMarket=dropOffInfo.market
            {
           
                if let pickupMarketId=pickupMarket.marketId,let dropOffMarketId=dropOffMarket.marketId, let symbolPosition=pickupMarket.symbolPosition, Int(dropOffMarketId)!==Int(pickupMarketId)!
                {
            
            if (Int(symbolPosition)! == 0)
                {
                self.presentPaymentTypes()
            }
                else
                {
            
            self.submitRequestCash()
                }
            }
            }
           
           
            
            
        })
        
        
     let controller = UIAlertController(title: "Tip", message: "Please tip", preferredStyle: .alert)
        controller.addTextField(configurationHandler: {textField in
            textField.translatesAutoresizingMaskIntoConstraints=false
            self.customTipTextField=textField
            
        })
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
    
    func calculateDeliveryFee(dropOffInfo:DeliveryInfo,pickupInfo:DeliveryInfo,dist:@escaping(Distance)->Void) {
        
        var pdInfo=[String:String]()
        var pdInfoString=""
        if let pickupAddress=pickupInfo.address, let dropOffAddress=dropOffInfo.address
        {
        pdInfo["pickup_address"]=pickupAddress
        pdInfo["delivery_address"]=dropOffAddress
        }
        do {
            self.rawData = try JSONSerialization.data(withJSONObject: pdInfo, options: .init(rawValue: String.Encoding.utf8.rawValue))
            let st = NSString(data: self.rawData!, encoding: String.Encoding.utf8.rawValue)
            pdInfoString = st as! String
            print(pdInfoString)
        } catch {
            print("Problem")
        }
        
        distance.getDistance(distanceInfo: pdInfoString, completion: {
            success,error,response in
            if let distance = self.distance.distance
            {
                dist(distance)
            }
                
                
           
        })
       
    }
    
    func submitRequest(_ nonce:String,_ squareCustomerId:String?,completion:@escaping SearchCompleteWithErrorAndStatus) -> Void {
        self.paymentInfo["fee"]=deliveryFee
        self.paymentInfo["type"]=0
        self.paymentInfo["token"]=nonce
        self.paymentInfo["square_customer_id"]=squareCustomerId
        self.info["order_info"]=self.orderInfo
        self.info["pickup_info"]=self.pInfo
        self.info["delivery_info"]=self.dInfo
        self.info["payment_info"]=self.paymentInfo
        var myString:String?
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
        self.shared.showLoadingView(view: self.view)
        
        self.deliveryInfo.requestDelivery(orderInfo: myString!, completion: {
            success,error,httpResponse in
            /*if(success)
            {
                self.shared.hideLoadingView()
                self.shared.showTaskCompletedView(view: self.view)
                
            }
            else
            {
                print(error?.localizedDescription)
            }*/
            
            completion(success,error,httpResponse)
            
            
            
        })
    }
    
    func submitRequestCash() -> Void {
        self.paymentInfo["fee"]=deliveryFee
        self.paymentInfo["type"]=0
        self.info["order_info"]=self.orderInfo
        self.info["pickup_info"]=self.pInfo
        self.info["delivery_info"]=self.dInfo
        self.info["payment_info"]=self.paymentInfo
        self.info["order_total"]=deliveryFee+customTipValue
        var myString:String?
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
        self.shared.showLoadingView(view: self.view)
        
        self.deliveryInfo.requestDeliveryCash(orderInfo: myString!, completion: {
            success,error,httpResponse in
            if(success)
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    self.shared.showTaskCompletedView(view: self.view)
                }
              
              
             
                
            }
            else
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    
                }
            }
            
        })
    }
    
}
extension DeliveryRequestViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "orderTypeCell") as! OrderTypeCell
        if indexPath.row==0 {
            if let pickupInfo=pickupInfo
            {
                cell.address.text=pickupInfo.address
                
            }
            else
            {
                cell.address.text="Enter Pickup address"
                
            }
            
            
        }
        else
        {
            if let dropOffInfo=dropOffInfo
            {
                cell.orderType.text="Delivery to:"
                cell.address.text=dropOffInfo.address
            }
            else
            {
                cell.orderType.text="Delivery to:"
                cell.address.text="Enter Delivery address"
            }
            
        }
        
        
    return cell
        
    }
    
    
    
}

extension DeliveryRequestViewController:UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row==0
        {
            showPickup()
            
        }
        else
        {
            showDelivery()
            
        }
    }
    
    
    
}
extension DeliveryRequestViewController:SFSafariViewControllerDelegate
{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let invoiceUrl = deliveryInfo.invoiceUrl
        {
        let invoiceUrlArray = invoiceUrl.pathComponents.split(separator: "/")
        let invoiceUrlSubArray=invoiceUrlArray[invoiceUrlArray.count-1]
        let order=Order()
            let transactionId=invoiceUrlSubArray[invoiceUrlSubArray.count]
            
            order.getOrderByTransactionId(transactionId: transactionId , completion: {
                success, error in
                
                if success
                {
                    DispatchQueue.main.async {
                        self.shared.showTaskCompletedView(view: self.view)
                    }
              
                    
                }
            })
           
        }
    }

}

extension DeliveryRequestViewController: PaymentTypesDelegate {
    func didRequestPayWithNewCard(paymentMethodNonce: String, completionHandler: @escaping (Error?) -> Void) {
        
        submitRequest(paymentMethodNonce,nil) {(success,error,HTTPURLResponse)
            in
            
            if success {
               
                DispatchQueue.main.async {
                self.shared.hideLoadingView()
                self.shared.showTaskCompletedView(view: self.view)
                    if (self.paymentTypesViewController != nil)
                    {
                    
                        self.paymentTypesViewController?.dismiss(animated: true)
                        print("View Controller not nil")
                        
                    }
                    else
                    {
                        print("View Controller nil")
                        
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
            
            
                completionHandler(nil)
                return
            }
            else if let error=error
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    completionHandler(error)
                }
                
                
            }
            else
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    completionHandler(error)
                }
                
               
                
            }
        }
        
        
        
    }
    
    func didRequestPayWithSavedCard(card: Card) {
        submitRequest(card.cardId,card.customerId) {(success,error,HTTPURLResponse)
            in
            
            if success {
               
                DispatchQueue.main.async {
                self.shared.hideLoadingView()
                self.shared.showTaskCompletedView(view: self.view)
                self.paymentTypesViewController?.dismiss(animated: true)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
            
            
               
                return
            }
            else if let error=error
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    
                }
                
                
            }
            else
            {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    
                }
                
               
                
            }
        }
    }
    
   
}









