//
//  SignUpViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/28/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var repeatPassWord: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInLinkButton: UIButton!
    var hello:String?
    var customerInfoDict=[String:Any]()
    var emptyFieldMessages=[String]()
    var textFieldsArray=[UITextField]()
    var defaults = UserDefaults.standard
    var customer = Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
    var operationStatus=false
    @IBAction func signUp(_ sender: Any) {
        if (checkFields())
        {
            return
        }
        if passWord.text != repeatPassWord.text
        {
            displayMessage(message: "Please make sure the passwords match.", title: "Passwords mismatch!")
            return
        }
        customerInfoDict["first_name"]=firstName.text
        customerInfoDict["last_name"]=lastName.text
        customerInfoDict["email"]=email.text
        customerInfoDict["phone"]=phoneNumber.text
        customerInfoDict["password"]=passWord.text
        let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
        let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
        let customerInfo = st! as String
        customer.createCustomer(customerInfo: customerInfo, completion: { [self]success,error,message in
            
            if(success)
            {
                
             
               self.operationStatus=success
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account successfully created", title: "Success")
                }
                
               
               
            }
           
            else if let error=error
            {
                DispatchQueue.main.async {
                    self.displayMessage(message: "Account was not created for the following reason: \(error.localizedDescription)", title: "Failure")
                    
                }
                
            }
            else
            {
                DispatchQueue.main.async {
                                   self.displayMessage(message: "Account was not created for the following reason: \(message)", title: "Failure")
                                   
                               }
                               
                
            }
        } )
            }
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        phoneNumber.delegate = self
        passWord.delegate = self
        repeatPassWord.delegate = self
        firstName.text = hello
        signUpButton.layer.cornerRadius=5
        signUpButton.clipsToBounds=true
        signInLinkButton.layer.cornerRadius=5
        signInLinkButton.layer.borderWidth=3
        signInLinkButton.layer.borderColor = UIColor(red: 255/255, green: 165/255, blue: 0, alpha:1).cgColor
        signInLinkButton.clipsToBounds=true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard)))


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
       
    @objc func dismissKeyBoard()
    {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        email.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        passWord.resignFirstResponder()
        repeatPassWord.resignFirstResponder()
    }
    

    @IBAction func dissmissSignUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    func isTextFieldEmpty(textField:UITextField) -> Bool {
        return textField.text!.isEmpty
    }
    
    func displayMessage(message:String,title:String)
        
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { [self]_ in
            if self.operationStatus
            {
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
                        self.presentingViewController?.dismiss(animated: true)
                        }
                        }
                        
                        
                    }
                })
            }
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func checkFields() ->  Bool {
        if(textFieldsArray.isEmpty)
              {
               textFieldsArray.append(firstName)
               textFieldsArray.append(lastName)
               textFieldsArray.append(phoneNumber)
               textFieldsArray.append(email)
                textFieldsArray.append(passWord)
                textFieldsArray.append(repeatPassWord)
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
                           emptyFieldMessages.append("Please provide your first name")
                       case 1:
                           emptyFieldMessages.append("Please provide your last name")
                       case 2:
                           emptyFieldMessages.append("Please provide your phone number")
                       case 3:
                           emptyFieldMessages.append("Please provide your email address")
                        case 4:
                            emptyFieldMessages.append("Please provide a password")
                        case 5:
                            emptyFieldMessages.append("Please provide confirm password")
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
                
                displayMessage(message: errors, title: "Empty fields");
                 return true
               }
            else
               {
                return false
           }
    }

}
