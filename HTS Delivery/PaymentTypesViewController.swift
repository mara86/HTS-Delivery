//
//  PaymentTypesViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 1/9/24.
//  Copyright © 2024 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import SquareInAppPaymentsSDK

protocol PaymentTypesDelegate
{
    func didRequestPayWithNewCard(paymentMethodNonce:String,completionHandler: @escaping (Error?) -> Void)
    func didRequestPayWithSavedCard(card:Card)
    
}

protocol NewCardDelegate
{
    func didRequestPayWithCard()
    
}

class PaymentTypesViewController: UIViewController {
    
    var card=Card()
    
    var defaults = UserDefaults.standard
    
    var customer : Customer?
    
    var customerInfoDict = [String:Any]()
    
    var cards=[Card]()
    
    var paymentTypesDelegate : PaymentTypesDelegate?
    
    var newCardDelegate:NewCardDelegate?
    
    var paymentTypesViewController:PaymentTypesViewController?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=100
        tableView.layer.cornerRadius=5
        newCardDelegate=self
        
        
        
        
        
        if let decodedCustomer = defaults.object(forKey: "customerInfo") as? Data
        {
            customer = NSKeyedUnarchiver.unarchiveObject(with: decodedCustomer) as? Customer
            
            customerInfoDict["customer_id"]=customer!.customerId
           let toServer = try! JSONSerialization.data(withJSONObject: customerInfoDict, options: .init(rawValue:String.Encoding.utf8.rawValue))
           let st = NSString(data: toServer, encoding: String.Encoding.utf8.rawValue)
           let customerInfo = st! as String
            
            card.retriveCards(customerInfo: customerInfo, completion: { success,error in
                
                
                if success
                {
                    self.cards=self.card.cards.cards
                    self.tableView.reloadData()
                    
                }
                
            })
        }
        
       
        
        
        

        // Do any additional setup after loading the view.
    }
    

  
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
               if touch?.view != self.tableView
               { self.dismiss(animated: true, completion: nil) }
    }
    
    private func didTapPayButton() {
      newCardDelegate?.didRequestPayWithCard()
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
extension PaymentTypesViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row<cards.count)
        {
            
            let card = cards[indexPath.row]
            
            paymentTypesDelegate?.didRequestPayWithSavedCard(card: card)
        }
        else
        {
            didTapPayButton()
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     
        
        if (indexPath.row<cards.count)
        {
          let  cell = tableView.dequeueReusableCell(withIdentifier: "savedCardCell") as! SavedCardTableViewCell
            let card = cards[indexPath.row]
            cell.cardName.text="\(card.cardBrand) .... \(card.last4)"
            cell.cardExpDate.text="\(card.expirationMonth)/\(card.expirationYear)"
            
            return cell
            
        }
        else
        {
          let  cell = tableView.dequeueReusableCell(withIdentifier: "newCardCell")
            
            return cell!
            
        }
        
       
        
    }
    
}
extension PaymentTypesViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count+1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension PaymentTypesViewController: NewCardDelegate {
    func didRequestPayWithCard() {
        
        let vc = self.makeCardEntryViewController()
        vc.delegate = self

        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
        
      
    }
}


extension PaymentTypesViewController {
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
extension PaymentTypesViewController: SQIPCardEntryViewControllerDelegate {
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
        paymentTypesViewController?.dismiss(animated: true)
        
        paymentTypesDelegate?.didRequestPayWithNewCard(paymentMethodNonce: cardDetails.nonce, completionHandler: completionHandler)

           
       

   
}
}




