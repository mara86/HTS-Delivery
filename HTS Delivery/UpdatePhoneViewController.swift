//
//  UpdatePhoneViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/28/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class UpdatePhoneViewController: UIViewController {
    var customerInfoDict=[String:Any]()
    var customer=Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
    @IBOutlet weak var updatePhoneButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBAction func updatePhone(_ sender: UIButton) {
        guard let currentCustomer=Customer.retrieveCustomer(),!phoneTextField.text!.isEmpty else {
            displayMessage(message: "Enter new phone number please.", title: "Enter Phone.")
            return
        }
        customerInfoDict["first_name"]=""
        customerInfoDict["last_name"]=""
        customerInfoDict["email"]=""
        customerInfoDict["phone"]=phoneTextField.text
        customerInfoDict["password"]=""
        customerInfoDict["zip_code"]=""
        customerInfoDict["customer_id"]=currentCustomer.customerId
       
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
               let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
               let customerInfo = st! as String
        customer.updateCustomer(customerInfo: customerInfo, completion: {success,error,response in
            
            if(success)
            {
                self.customer=currentCustomer
                DispatchQueue.main.async {
                    self.customer.phone=self.phoneTextField.text!
                    self.displayMessage(message: "Account successfully updated", title: "Success")
                }
                Customer.saveCustomer(customer: self.customer)
                
                
               
            }
            else if let response = response
            {
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account was not updated for the following reason: \(response.statusCode)", title: "Failure")
                    
                }
                
            }
            else if let error=error
            {
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account was not updated for the following reason: \(error.localizedDescription)", title: "Failure")
                    
                }
                
            }
            else
            {
                DispatchQueue.main.async {
                                   self.displayMessage(message: "Account was not updated", title: "Failure")
                                   
                               }
                               
                
            }
            
            
            
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard)))
        updatePhoneButton.layer.cornerRadius=5

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
       
    @objc func dismissKeyBoard()
    {
        phoneTextField.resignFirstResponder()
    }
    func isTextFieldEmpty(textField:UITextField) -> Bool {
          return textField.text!.isEmpty
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
