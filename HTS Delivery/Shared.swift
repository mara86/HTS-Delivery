//
//  Shared.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/1/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


class Shared {
    let urlToken = "https://www.htsdelivery.com/product.php"
    typealias TokenWithError = (String?,Error?)->Void
    var clientTokenToUse: String?
    var addresses=[Address]()
    var navBarController:UINavigationController?
    var titleLabel:UILabel?
    var defaults=UserDefaults.standard
    var decodedCustomer:Customer?
    var customerInfoDict=[String:Any]()
    var presentingViewController:UIViewController?
    var address=Address(id: "", street: "", zipCode: "", city: "", state: "", latitude: "", longitude: "", customerId: "", apt: "", completeAddress: "")
    let loadingView = UIView()
    
    let activityIndicator=UIActivityIndicatorView()
    let reloadingButton=UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
    var imageView=UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
    var thankMessage:UILabel?
    var orderPlaced:UILabel?
    func loadViewController(viewController:UIViewController,width:CGFloat) -> Void {
        self.presentingViewController=viewController
        if  viewController .isKind(of: SellersViewController.self)==true   {
            titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        }
        
        if let titleLabel = titleLabel
        {
        titleLabel.textAlignment = .center
        titleLabel.font=UIFont(name: titleLabel.font.fontName, size: 15)
        titleLabel.numberOfLines=0
        titleLabel.isUserInteractionEnabled=true
            titleLabel.textColor=UIColor.white
            if viewController.navigationController != nil
            {
            viewController.navigationItem.titleView = titleLabel
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewControllerToLoad))
        titleLabel.addGestureRecognizer(tapGestureRecognizer)
           /* if let customer = Customer.retrieveCustomer()
        {
                customerInfoDict["customer_id"]=customer.customerId
                let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
                      let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
                      let customerInfo = st! as String
                print(customerInfo)
            address.getAddress(customerId: customerInfo, completion: {success,error in
            
            if(success || error==nil)
            {
                if(self.address.addresses.count>0)
                {
                DispatchQueue.main.async {
                    titleLabel.text = self.address.addresses[0].completeAddress
                    self.addresses=self.address.addresses
                }
               }
                else
                {
                    DispatchQueue.main.async {
                    titleLabel.text = "ADD ADDRESS"
                }
                   
                }
            }
        })
        }*/
            if let orderInfo = OrderInfo.getOrderInfo() {
                if orderInfo.orderType==1 && orderInfo.address != nil
                {
                titleLabel.text = "Delivery to:"+orderInfo.address!.completeAddress
                }
                else if orderInfo.orderType==0, let seller=Seller.retrieveSeller(),let address=seller.address
                {
                    titleLabel.text = "Pickup from: "+address
                }
               
               }
                else
                {
                   
                    titleLabel.text = "ADD ADDRESS"
              
              
            }
        }
       
    }
    
    @objc func viewControllerToLoad()
       {
      navBarController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderTypeNavBar") as? UINavigationController)
           
           if let orderTypeViewController = navBarController?.viewControllers.first as? OrderTypeViewController
           {
               if let viewController = presentingViewController as? SellersViewController
               {
                   orderTypeViewController.addressSelectionDelegate=viewController
                 
               }
               
           }
        if let viewController = presentingViewController
        {
          viewController.present(navBarController!, animated: true, completion: nil)
        }
        
       }
    
    func placePhoneCall(phoneNumber:String) -> Void {
        if let number = URL(string: "tel://"+phoneNumber)
        {
            if UIApplication.shared.canOpenURL(number)
            {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
            }
        }
    }
    
    func showLoadingView(view:UIView) -> Void {
        loadingView.frame =  view.frame
        loadingView.backgroundColor=UIColor.white
        activityIndicator.center=loadingView.center
        loadingView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.color = .black
        view.addSubview(loadingView)
        
    }
    func hideLoadingView() -> Void {
           activityIndicator.stopAnimating()
           activityIndicator.removeFromSuperview()
           loadingView.removeFromSuperview()
        
           
       }
    
    func showReloadingView(view:UIView) -> UIButton {
        loadingView.frame=view.frame
        reloadingButton.setTitle("Retry", for: .normal)
        reloadingButton.center=loadingView.center
        reloadingButton.isUserInteractionEnabled=true
        reloadingButton.isEnabled=true
        reloadingButton.backgroundColor = .orange
        reloadingButton.titleLabel?.textColor = .black
        loadingView.addSubview(reloadingButton)
        view.addSubview(loadingView)
        return reloadingButton
        
        
    }
    func hideReloadingView() -> Void {
        reloadingButton.removeFromSuperview()
        loadingView.removeFromSuperview()
    }
    
    func showTaskCompletedView(view:UIView) -> Void {
         loadingView.frame=view.frame
         imageView.image=UIImage(named: "task-completed.png")
         imageView.center=loadingView.center
         loadingView.addSubview(imageView)
         orderPlaced=UILabel(frame: CGRect(x: view.frame.midX-75, y: view.frame.midY-imageView.frame.height, width: 150, height: 50))
         thankMessage=UILabel(frame: CGRect(x: view.frame.midX-150, y: view.frame.midY+imageView.frame.height, width: 300, height: 30))
         if let thankMessage=thankMessage
         {
         thankMessage.text="Thank you for using Hts Delivery."
         thankMessage.textColor = UIColor.black.withAlphaComponent(0.5)
         thankMessage.textAlignment = .center
         loadingView.addSubview(thankMessage)
         }
        if let orderPlaced=orderPlaced
        {
            orderPlaced.text="Order Placed"
            orderPlaced.textColor = .black
            orderPlaced.textAlignment = .center
            loadingView.addSubview(orderPlaced)
        }
         loadingView.backgroundColor = .white
         view.addSubview(loadingView)
     
       }
    func hideTaskCompletedView() -> Void {
        imageView.removeFromSuperview()
        loadingView.removeFromSuperview()
    }
    func fetchClientToken(completion:@escaping TokenWithError) {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: urlToken)!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            if let data = data
            {
                
                let clientToken = String(data: data, encoding: String.Encoding.utf8)
                self.clientTokenToUse = clientToken!
                completion(clientToken,nil)
                
            }
            else if let error = error
            {
                completion(nil,error)
                
            }
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }
    
   /* func showDropIn(clientTokenOrTokenizationKey: String,viewcontroller:UIViewController, paymentResult: @escaping (BTDropInResult?)->Void) {
        DispatchQueue.main.async {
            self.showLoadingView(view: viewcontroller.view)
        }
       
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCanceled == true) {
                print("CANCELLED")
            } else if result != nil {
                //self.postNonceToServer(paymentMethodNonce: "fake-valid-nonce")
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                paymentResult(result)
              
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        if let dropIn = dropIn
        {
            DispatchQueue.main.async {
                self.hideLoadingView()
                 viewcontroller.present(dropIn, animated: true, completion: nil)
            }
       
        }
        else
        {
            print("Error")
        }
    }*/
    
    func showSign(presentingViewController:UIViewController) -> Void {
        let viewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavigationController") as! UINavigationController)
        presentingViewController.present(viewController, animated: true)
    }
    
    func showItemInstructionsVC(presentingViewController:AddOnsTableViewController) -> Void {
        let viewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemInstructionsVC") as! UINavigationController)
        
        presentingViewController.present(viewController, animated: true)
    }
    
    
   static func displayMessage(message:String,title:String,viewController:UIViewController)
        
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
}

