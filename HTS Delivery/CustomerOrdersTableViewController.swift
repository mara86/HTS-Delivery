//
//  CustomerOrdersTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/21/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CustomerOrdersTableViewController: UITableViewController {
    
    var customerOrder = CustomerOrder()
    var defaults=UserDefaults.standard
    var customer:Customer?
    var shared=Shared()
    
    @objc func swipeHandler() {
       
            print("Swiped")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight=80
        title="Orders"
        shouldReloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData), name: NSNotification.Name(rawValue: "newOrder"), object: nil)
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeGestureRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeGestureRecognizer)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.customerOrder.customerOrders.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = customerOrder.customerOrders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerOrderCell", for: indexPath) as! CustomerOrderTableViewCell
        
        cell.orderNumberLabel.text="Order # \(order.order!.orderNumber)"
        if let name = String(htmlEncodedString: order.seller!.name!)
        {
        cell.sellerLabel.text=name
        }
        if let courier=order.courier, order.address != nil
        {
        cell.courierLabel.text="\(courier.firstName) \(courier.lastName)"
        }
        else
        {
             cell.courierLabel.text="Pickup order"
            
        }
       
        
        

        // Configure the cell...

        return cell
    }
    
    
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if #available(iOS 10.0, *) {
            
           
            if  let indexPath = tableView.indexPathForSelectedRow
            {
            if let orderDeatilViewController =  segue.destination as? OrderDetailViewController
            {
                orderDeatilViewController.customerOrder=customerOrder.customerOrders[indexPath.row]
            }
            }
        }
        else {
            // Fallback on earlier versions
        }
         
    }
    
   @objc func shouldReloadData() -> Void {
    DispatchQueue.main.async {
        self.shared.showLoadingView(view: self.view)
    }
      
        if let decodedCustomer = defaults.object(forKey: "customerInfo") as? Data
                        {
                            customer = NSKeyedUnarchiver.unarchiveObject(with: decodedCustomer) as? Customer
                        
        
          customerOrder.getCustomerOrders(customerId: customer!.customerId, completion: {success,error in
              if(success)
              {
                  if(self.customerOrder.customerOrders.count>0)
                  {
                      
                      DispatchQueue.main.async {
                         self.shared.hideLoadingView()
                         self.tableView.reloadData()
                          
                      }
                  }
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                                         
                                     }
                
              
              } else if error != nil
              {
                DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    let button = self.shared.showReloadingView(view: self.view)
                    button.addTarget(self, action: #selector(self.shouldReloadData), for: UIControl.Event.touchUpInside)
                                   
                }
                
                
              }
            else
              {
                DispatchQueue.main.async {
                                  self.shared.hideLoadingView()
                                                 
                              }
                              
               
            }
            
              })
          }
    }
    

}
