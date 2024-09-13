//
//  PasswordResetRequestViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 8/14/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class PasswordResetRequestViewController: UIViewController {
    var customerInfoDict=[String:Any]()
    var emptyFieldMessages=[String]()
    var textFieldsArray=[UITextField]()
    
     var customer=Customer(customerId: 0, firstName: "", lastName: "", email: "", phone: "", zipCode: "",password: "")
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var requestButton: UIButton!
    
    @IBAction func cancelRequest(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func submitRequest(_ sender: UIButton) {
        
        if(textFieldsArray.isEmpty)
        {
            textFieldsArray.append(emailTextField)
         
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
                    emptyFieldMessages.append("Please enter your email address")
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
            displayMessage(message: errors, title: "Empty field")
            
            return
        }
       
       
             customerInfoDict["email"]=emailTextField.text
            let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
            let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
            let customerInfo = st! as String
            customer.requestPasswordReset(customerInfo: customerInfo, completion: {
                success,error,response in
                
                if success
                {
                    DispatchQueue.main.async {
                        self.displayMessage(message: "Please check your email for a link to update your password.", title:"Link sent" )
                    }
                }
            })
            
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestButton.layer.cornerRadius=5
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard)))

        // Do any additional setup after loading the view.
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
       
    @objc func dismissKeyBoard()
    {
        emailTextField.resignFirstResponder()
        
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
