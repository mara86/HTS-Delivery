//
//  PaymentViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/16/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit


class  LoginViewController:UIViewController,UITextFieldDelegate
{
    var clientTokenToUse: String?
    var defaults = UserDefaults.standard
    var decodedCartItems = [Product]()
    var customerInfoDict=[String:Any]()
    var downloadTask: URLSessionDownloadTask?
    var dataToSend = [String:Any?]()
    var myString : String?
    var rawData: Data?
    var dictionaries = [[String:Any]]()
    var amount:Double = 0.0
    var emptyFieldMessages=[String]()
    var textFieldsArray=[UITextField]()
    var tabBarControl:TabBarController?
    var customer=Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
    var decodedCustomer:Customer?
    @IBOutlet weak var signUpButtonLink: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func cancelSigningIn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func browseMerchants(_ sender: Any) {
        tabBarControl=(UIApplication.shared.delegate as! AppDelegate).getRootViewController()
        if let tabBarControl = tabBarControl {
            if let viewControllers = tabBarControl.viewControllers, let
                    navigationController=viewControllers[0] as? UINavigationController
            {
                  
                tabBarControl.selectedViewController=navigationController
                self.dismiss(animated: true, completion: nil)
            }
        }
       
    }
    @IBAction func login(_ sender: Any) {
       if( self.checkFields())
       {
        return
        }
        customerInfoDict["email"]=email.text
        customerInfoDict["password"]=password.text
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
              let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
              let customerInfo = st! as String
        customer.getCustomer(customerInfo: customerInfo, completion: {success, errror in
            if(success)
            {
                
                if let customer = self.customer.customer
                {
                    let encodedData:Data = try! NSKeyedArchiver.archivedData(withRootObject: customer, requiringSecureCoding: true)
                    self.defaults.set(encodedData, forKey: "customerInfo")
                    self.defaults.set(true, forKey: "isUserLoggedIn")
                    self.defaults.synchronize()
                DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                }
                }
                
                
            }
            else
            {
                DispatchQueue.main.async {
                    if let error=errror
                    {
                        self.displayMessage(message: error.localizedDescription, title: "Error")
                    
                    }
                    else
                    {
                         self.displayMessage(message: "We could not log you in. Please retry", title: "Error")
                    }
                }
               
            }
            
            
        })
    }
    
   /* @IBAction func showSignUpForm(_ sender: Any) {
        performSegue(withIdentifier: "signup", sender: self)
        
    }*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signup"
        {
           if let signUpViewController = segue.destination as? SignUpViewController
            
            {
                signUpViewController.hello = "Moussa"
                
            }
        }
    
    }
    override func viewDidLoad() {
        email.delegate = self
        password.delegate = self
        signInButton.layer.cornerRadius=5
        signInButton.clipsToBounds=true
        signUpButtonLink.layer.cornerRadius=5
        signUpButtonLink.layer.borderWidth=3
        signUpButtonLink.layer.borderColor = UIColor(red: 255/255, green: 165/255, blue: 0, alpha: 1).cgColor
        
        signUpButtonLink.clipsToBounds=true
       
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard)))
    }

    
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyBoard()
    {
    email.resignFirstResponder()
    password.resignFirstResponder()
    
    }
    
    func checkFields() -> Bool {
        if(textFieldsArray.isEmpty)
              {
              textFieldsArray.append(email)
              textFieldsArray.append(password)
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
                           emptyFieldMessages.append("Please provide your email address")
                        case 1:
                            emptyFieldMessages.append("Please provide a password")
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
                   return true
                  
               }
        else
               {
                return false
        }
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
    }
