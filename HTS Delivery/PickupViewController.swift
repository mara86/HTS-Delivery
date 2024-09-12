//
//  PickupViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/26/22.
//  Copyright © 2022 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class PickupTableViewController: UITableViewController {
    
    var emptyFieldMessages=[String]()
    var textFieldsArray=[UITextField]()
    var formattedAddress:String?
    var delegate:UserInformationDelegate?
    var market:Market?
    
    @IBOutlet weak var pickupInstructions: UITextView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var telephone: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var apt: UITextField!
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func save(_ sender: Any) {
        if(textFieldsArray.isEmpty)
        {
            textFieldsArray.append(address)
            textFieldsArray.append(telephone)
            textFieldsArray.append(firstName)
            textFieldsArray.append(lastName)
           
            
            
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
                    emptyFieldMessages.append("Please enter your address")
                case 1:
                    emptyFieldMessages.append("Please enter your phone number")
                case 2:
                    emptyFieldMessages.append("Please enter your first name")
                default:
                    emptyFieldMessages.append("Please enter your last name")
                    
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
        let deliveryInfo=DeliveryInfo()
        deliveryInfo.address=address.text
        deliveryInfo.lastName=lastName.text
        deliveryInfo.firstName=firstName.text
        deliveryInfo.apt=apt.text
        deliveryInfo.telephone=telephone.text
        deliveryInfo.instructions=pickupInstructions.text
        deliveryInfo.type="pickup"
        deliveryInfo.market=market
        delegate?.wasUserInfoSaved(deliveryInfo: deliveryInfo)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickupInstructions.layer.borderColor=UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pickupInstructions.layer.borderWidth=1
        pickupInstructions.layer.cornerRadius=5
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard)))
        if let formattedAddress = formattedAddress {
            address.text=formattedAddress
        }

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
       
    @objc func dismissKeyBoard()
    {
        pickupInstructions.resignFirstResponder()
        address.resignFirstResponder()
        telephone.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        apt.resignFirstResponder()
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
