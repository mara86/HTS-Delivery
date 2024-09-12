//
//  PasswordUpdateViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/30/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class PasswordUpdateViewController: UIViewController {
    var emptyFieldMessages=[String]()
    var textFieldsArray=[UITextField]()
    var customerInfoDict=[String:Any]()
    var decodedCustomer:Customer?
     var customer=Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
    let defaults=UserDefaults.standard
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBAction func updatePassword(_ sender: UIButton) {
               if(textFieldsArray.isEmpty)
               {
                   textFieldsArray.append(currentPasswordTextField)
                   textFieldsArray.append(newPasswordTextField)
                   textFieldsArray.append(confirmPasswordTextField)
               }
               
               if(!emptyFieldMessages.isEmpty)
               {
                   emptyFieldMessages.removeAll()
               }
               for textField in textFieldsArray {
                   
                   if isTextFieldEmpty(textField: textField)
                   {
                       changeEmptyFieldBorderColor(textField: textField,color: UIColor.red)
                    switch textFieldsArray.firstIndex(of: textField)
                       {
                           
                       case 0:
                           emptyFieldMessages.append("Please provide your current password")
                       case 1:
                           emptyFieldMessages.append("Please provide your new password")
                       case 2:
                           emptyFieldMessages.append("Please confirm new password")
                       default:
                           emptyFieldMessages.append("Please provide required info")
                           
                       }
                   }
                   else
                   {
                       changeEmptyFieldBorderColor(textField: textField, color: UIColor.white)
                   }
               }
               
               if(emptyFieldMessages.count>0)
               {
                   var errors=""
                   
                   for errorMessage in emptyFieldMessages
                   {
                       errors+=errorMessage+"\n"
                       
                   }
                   displayMessage(message: errors, title: "Empty fields")
                   
                   return
               }
        guard confirmPasswordTextField.text==newPasswordTextField.text else {
            
            displayMessage(message: "New password does not match confirm password.", title: "Passwords mismatch")
            return
        }
        if let decodedCustomer=Customer.retrieveCustomer()
               {
                
                customer.getCustomerById(customerId: "\(decodedCustomer.customerId)", completion: {success,error in
                    if(success)
                    {
                        if let currentCustomer=self.customer.customer,self.currentPasswordTextField.text==currentCustomer.password
                        {
                            self.customerInfoDict["first_name"]=""
                            self.customerInfoDict["last_name"]=""
                            self.customerInfoDict["email"]=""
                            self.customerInfoDict["phone"]=""
                            self.customerInfoDict["zip_code"]=""
                            self.customerInfoDict["customer_id"]=decodedCustomer.customerId
                            self.customerInfoDict["password"]=self.newPasswordTextField.text
                           
                        
                            let toServer = try! JSONSerialization.data(withJSONObject: self.customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
                                          let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
                                          let customerInfo = st! as String
                            self.customer.updateCustomer(customerInfo: customerInfo, completion: {success,error,status in
                                
                                if(success)
                                {
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else if error != nil
                                {
                                    DispatchQueue.main.async {
                                        self.displayMessage(message: error!.localizedDescription, title: "Error")
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        self.displayMessage(message: "There was error; we could not update your password", title: "Error")
                                    }
                                   
                                }
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.displayMessage(message: "Please enter the current password", title: "Passwords mismatch")
                            }
                             
                            
                            
                        }
                        
                    }
                    else if error != nil
                    {
                        DispatchQueue.main.async {
                            self.displayMessage(message: error!.localizedDescription, title: "Error")
                        }
                        
                        
                        
                    }
                    else
                    {
                        DispatchQueue.main.async {
                             self.displayMessage(message: error!.localizedDescription, title: "Error")
                        }
                       
                        
                    }
                })
                   
               }
               
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard)))
        updatePasswordButton.layer.cornerRadius=5

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
       
       func changeEmptyFieldBorderColor(textField:UITextField,color:UIColor)
       {
           if color == UIColor.red {
               
               
               textField.layer.borderWidth=1.0
               textField.layer.borderColor = color.cgColor
               textField.clipsToBounds=true
           }
           else
           {
               textField.layer.borderWidth=0.0
           }
       }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
       
    @objc func dismissKeyBoard()
    {
        currentPasswordTextField.resignFirstResponder()
        newPasswordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
       
       

}
