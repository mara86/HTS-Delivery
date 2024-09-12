//
//  SOPullUpTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 5/2/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
//import SOPullUpView
import MapKit
import UBottomSheet

class SOPullUpTableViewControllerPickup: UITableViewController, Draggable,UserLocationProtocol {
    func wasLocationUpdated(userLocation: CLLocation) {
        updateEta(userLocation: userLocation)
    }
    
    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var orderEta: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var restName: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBAction func call(_ sender: Any) {
        if let customerOrder = customerOrder, let seller = customerOrder.seller, let phone=seller.phone
        {
            shared.placePhoneCall(phoneNumber: phone)
        }
    }
    
   /* var pullUpControl: SOPullUpControl? {
        didSet {
            pullUpControl?.delegate = self
        }
    }*/
    
    var customerOrder:CustomerOrder?
    var shared=Shared()
    var mostRecentLocation:CLLocation?
    var sheetCoordinator: UBottomSheetCoordinator?
    override func viewWillAppear(_ animated: Bool) {
        //adds pan gesture recognizer to draggableView()
            sheetCoordinator?.startTracking(item: self)
        }
    func draggableView() -> UIScrollView? {
           return tableView
       }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableView.automaticDimension
       
        updateUI()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateUI() -> Void {
        handle.layer.cornerRadius=3
        tableView.layer.cornerRadius=10
        callButton.layer.cornerRadius=15
        callButton.layer.borderWidth=1
        callButton.layer.borderColor=UIColor(displayP3Red: 255/255, green: 165/255, blue: 0, alpha: 1).cgColor
        if let customerOrder=customerOrder
        {
            self.orderStatus.text=formattedstatus(status:customerOrder.order!.restStatus)
            if let name=customerOrder.seller?.name
            {
                restName.text=String(htmlEncodedString:name)
            }
            orderNumber.text=customerOrder.order?.orderNumber
            streetAddress.text=customerOrder.seller?.address
           
            
        }
    }
    
    func updateEta(userLocation:CLLocation) -> Void {
        if let customerOrder = customerOrder {
          if  let seller=customerOrder.seller,let lat=seller.latitude,let long=seller.longitude
            {
                
                
            let latLong = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
              let latLongCustomer=CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let courierPoint = MKPointAnnotation()
             courierPoint.coordinate=latLong
             let customerPoint = MKPointAnnotation()
             customerPoint.coordinate=latLongCustomer
             let source = MKPlacemark(coordinate: latLong)
            let destination = MKPlacemark(coordinate: latLongCustomer)
                let mkDRequest=MKDirections.Request()
                mkDRequest.source=MKMapItem(placemark: source)
                mkDRequest.destination=MKMapItem(placemark: destination)
                
             let mkDir = MKDirections(request: mkDRequest)
           
                mkDir.calculate(completionHandler: { response, error in
                                  if let response = response
                                  
                                  {
                                let eta = Int(response.routes[0].expectedTravelTime/60)
                                self.orderEta.text="\(eta)-\(eta+5)"

                                      }
                                      
                                  }
                                )
            }
            else
            {
                print("Not eta")
            }
            
        }
        
    }
    
    func formattedstatus(status:String) -> String {
        var sta=""
        switch status {
        case "pending":
            sta="Order received"
        case "confirmed":
            sta="Order confirmed"
        case "ready":
            sta="Order ready"
        default:
            sta="Order received"
        }
        
        return sta
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
   /* override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text="Moussa"

        // Configure the cell...

        return cell
    }*/
    

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

}

/*extension SOPullUpTableViewControllerPickup:SOPullUpViewDelegate
{
    func pullUpViewStatus(_ sender: UIViewController, didChangeTo status: PullUpStatus) {
        switch status {
           case .collapsed:
            print("Collapsed")
           case .expanded:
            print("Expanded")
        }
    }
    
    func pullUpHandleArea(_ sender: UIViewController) -> UIView {
        let handle = UIView(frame: CGRect(x: sender.view.frame.midX-25, y: 10, width: 50, height: 5))
        handle.layer.cornerRadius=2
        handle.backgroundColor=UIColor(displayP3Red: 255/255, green: 165/255, blue: 0, alpha: 0.5)
        sender.view.addSubview(handle)
        return handle
    }
    
    
    
    
}*/
    
    
