//
//  CartTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 12/1/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree


class CartTableViewController: UITableViewController {
    var clientTokenToUse: String?
    var defaults = UserDefaults.standard
    var decodedCartItems = [SearchResult]()
    var downloadTask: URLSessionDownloadTask?
    var dataToSend = [String:Any?]()
    var myString : String?
    var rawData: Data?
    var dictionaries = [[String:Any]]()
    var amount:Double = 0.0
    let url = "http://192.168.0.10:8080/projects/Project4/product.php"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = 80
        let cellNib = UINib(nibName: "CartCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "CartCell")
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
             decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [SearchResult]
        }
        fetchClientToken();


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return decodedCartItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let cartResult = decodedCartItems[indexPath.row]
        cell.itemImageView.layer.cornerRadius = 4
        cell.itemImageView.clipsToBounds = true
        cell.quantity.text = "\(cartResult.quantity)"
        cell.itemName.text = cartResult.designation
        if let url = URL(string: cartResult.imageUrl)
        {
        
            cell.itemImageView.loadImageWithURL(url)
        }
        cell.onButtonMinusPressed = {
            cell in
            if (cartResult.quantity > 1 )
            {
                cartResult.quantity = cartResult.quantity - 1
                let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
                self.defaults.set(encodedData, forKey: "cartItems")
                self.defaults.synchronize()
                tableView.reloadData()

                
            }

            
        }
        cell.onButtonPlusPressed = {
            cell in
            if (cartResult.quantity < 10)
            {
                cartResult.quantity = cartResult.quantity + 1
                let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
                self.defaults.set(encodedData, forKey: "cartItems")
                self.defaults.synchronize()
                tableView.reloadData()
                
                
            }
            
            
        }
        cell.onButtonDeletePressed =
            {
                cell in
                self.decodedCartItems.remove(at: indexPath.row)
                let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
                self.defaults.set(encodedData, forKey: "cartItems")
                self.defaults.synchronize()
                tableView.reloadData()
        }


        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.clientTokenToUse != nil)
        {
            
            self.showDropIn(clientTokenOrTokenizationKey: self.clientTokenToUse!)
        }
        else
        {
            print("You app failed to get a Token from remote server.Check your connection")
        }
        
    }
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: url)!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            if let data = data
            {
                
                let clientToken = String(data: data, encoding: String.Encoding.utf8)
                self.clientTokenToUse = clientToken!
                print(self.clientTokenToUse)
                
            }
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                self.postNonceToServer(paymentMethodNonce: "fake-valid-nonce")
                 // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    func postNonceToServer(paymentMethodNonce: String) {
        if(!dictionaries.isEmpty)
        {
            dictionaries.removeAll()
        }
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [SearchResult]
            for decodedItem in decodedCartItems {
                dataToSend["item_id"] = decodedItem.itemId
                dataToSend["designation"] = decodedItem.designation
                dataToSend["description"] = decodedItem.desc
                dataToSend["price"] = decodedItem.price
                dataToSend["quantity"] = decodedItem.quantity
                dictionaries.append(dataToSend)
                amount = amount + Double(decodedItem.price)!
                
            }
            if JSONSerialization.isValidJSONObject(dictionaries) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: dictionaries, options: .init(rawValue: String.Encoding.utf8.rawValue))
                    let st = NSString(data: rawData!, encoding: String.Encoding.utf8.rawValue)
                    myString = st as! String
                    print(myString)
                } catch {
                    print("Problem")
                }
            }
            
        }

        // Update URL with your server
        let paymentURL = URL(string: url)!
        var request = URLRequest(url: paymentURL)
        let products="data_to_send="+myString!;
        let payment="total="+String(amount);
        let payment_nonce="payment_method_nonce=\(paymentMethodNonce)";
        let data_to_server = products+"&"+payment+"&"+payment_nonce;
        request.httpBody = data_to_server.data(using: String.Encoding.utf8);
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            if (error != nil)
            {
                print(error ?? "error");
            }
            do {
                let fromServer = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let fromServerString = fromServer as? String
                print(fromServerString!)
            } catch {
                print(error)
            }

            // TODO: Handle success or failure
            }.resume()
    }

    
 

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
