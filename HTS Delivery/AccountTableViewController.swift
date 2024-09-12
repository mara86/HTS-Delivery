//
//  AccountTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/15/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import SafariServices
import SquareInAppPaymentsSDK

class AccountTableViewController: UITableViewController {
    
    let shared=Shared()
    let card=Card()
    
    var newCardDelegate:NewCardDelegate?
    
    let defaults = UserDefaults.standard
    
    var customerInfoDict = [String:Any]()
    
    var customer=Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
  
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerEmail:UILabel!
    
    @IBOutlet weak var customerPhone: UILabel!
    
    @IBOutlet weak var customerAddress: UILabel!
    
    @IBAction func updateDefaultAddress(_ sender: UIButton) {
        shared.presentingViewController=self
        shared.viewControllerToLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let status = Customer.retrieveCustomerStatus()
        if !status
        {
        performSegue(withIdentifier: "showLogin", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCardDelegate=self
       
        updateUI()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func didTapPayButton() {
      newCardDelegate?.didRequestPayWithCard()
   }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row==4
        {
            Customer.saveCustomerStatus(status: false)
        }
        if indexPath.row==5
        {
            let alertController=UIAlertController(title: "Account Deletion", message: "Do you really want to delete this account?", preferredStyle: .alert)
            let actionYes=UIAlertAction(title: "YES", style: .default, handler: { _ in
               
                self.deleteAccount()
              
            })
            
            let actionNo=UIAlertAction(title: "NO", style: .cancel, handler: { _ in
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            })
            
            alertController.addAction(actionYes)
            alertController.addAction(actionNo)
            present(alertController, animated: true)
            
            
        }
        if indexPath.row==6
        {
        let url = URL(string: "https://www.htsdelivery.com/privacy-policy.html")
            let vc = SFSafariViewController(url: url!)
           
           
                self.present(vc, animated: true)
          
            
        }
        if indexPath.row==7
        {
            let url = URL(string: "https://www.htsdelivery.com/terms-of-use.html")
                let vc = SFSafariViewController(url: url!)
               
               
                    self.present(vc, animated: true)
           
            
        }
        
        if indexPath.row==8
        {
            didTapPayButton()
            
               
               
           
            
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateUI() -> Void {
        if let customer = Customer.retrieveCustomer()
        {
            profileImageView.layer.borderWidth=2
                   profileImageView.layer.borderColor=UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1).cgColor
                   profileImageView.layer.cornerRadius=profileImageView.frame.width/2
                   profileImageView.clipsToBounds=true
            customerName.text="\(customer.firstName) \(customer.lastName)"
            customerEmail.text="\(customer.email)"
            print(customer.email)
            customerPhone.text="\(customer.phone)"
            if let address = Address.getDefaultAddress()
            {
                customerAddress.text=address.completeAddress
            }
            else
            {
                customerAddress.text="No Address"
            }
            
        }
    }
    
    func deleteAccount() -> Void {
        
        var customerInfoDict=[String:Any]()
        
        guard let currentCustomer=Customer.retrieveCustomer()
        else {
           
            return
        }
        customerInfoDict["first_name"]=""
        customerInfoDict["last_name"]=""
        customerInfoDict["email"]=""
        customerInfoDict["phone"]=""
        customerInfoDict["password"]=""
        customerInfoDict["zip_code"]=""
        customerInfoDict["customer_id"]=currentCustomer.customerId
        customerInfoDict["status"]="inactive"
       
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
               let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
               let customerInfo = st! as String
        customer.updateCustomer(customerInfo: customerInfo, completion: {success,error,response in
            
            if(success)
            {
                self.customer=currentCustomer
                DispatchQueue.main.async {
                    
                   self.displayMessage(message: "Account successfully deleted", title: "Success")
                    
                }
                Customer.saveCustomerStatus(status: false)
                
                
               
            }
            else if let response = response
            {
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account was not deleted for the following reason: \(response.statusCode)", title: "Failure")
                    
                }
                
            }
            else if let error=error
            {
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account was not deleted for the following reason: \(error.localizedDescription)", title: "Failure")
                    
                }
                
            }
            else
            {
                DispatchQueue.main.async {
                                   self.displayMessage(message: "Account was not deleted", title: "Failure")
                                   
                               }
                               
                
            }
            
            
            
        })
    }
    
    func displayMessage(message:String,title:String)
           
       {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
               DispatchQueue.main.async {
                   self.performSegue(withIdentifier: "showLogin", sender: self)
               }
              
               
           })
           alert.addAction(action)
           present(alert, animated: true, completion: nil)
       }

}

extension AccountTableViewController: NewCardDelegate {
    func didRequestPayWithCard() {
        
        let vc = self.makeCardEntryViewController()
        vc.delegate = self

        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
        
      
    }
}


extension AccountTableViewController {
    func makeCardEntryViewController() -> SQIPCardEntryViewController {
        let theme=SQIPTheme()
        theme.tintColor=UIColor(red: 255/255, green: 165/255, blue: 0, alpha: 1.0)
        let cardEntry = SQIPCardEntryViewController(theme: theme)
        cardEntry.collectPostalCode = true
        cardEntry.delegate = self
        return cardEntry
    }
}

//Handle the card entry success or failure from the card entry form
extension AccountTableViewController: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        
        
       
        
        // Note: If you pushed the card entry form onto an existing navigation controller,
            // use UINavigationController.popViewController(animated:) instead
          //  dismiss(animated: true, completion: nil)
    }
    
    func cardEntryViewController(_: SQIPCardEntryViewController,
                                    didObtain cardDetails: SQIPCardDetails,
                                    completionHandler: @escaping (Error?) -> Void) {
           // Send card nonce to your server to store or charge the card.
           // When a response is received, call completionHandler with `nil` for success,
           // or an error to indicate failure.
        if let customer = Customer.retrieveCustomer()
        {
           
            
            customerInfoDict["customer_id"]=customer.customerId
            customerInfoDict["token"]=cardDetails.nonce
            customerInfoDict["zip_code"]=cardDetails.card.postalCode
           
           let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
           let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
           let customerInfo = st! as String
            
            self.card.saveCard(cardInfo: customerInfo, completion: {
                success,error,message in
                
                if success
                {
                    completionHandler(nil)
                    self.dismiss(animated: true)
                }
                else
                {
                   completionHandler(error)
                }
                
                
            })
        }
       
           
       

   
}
}

