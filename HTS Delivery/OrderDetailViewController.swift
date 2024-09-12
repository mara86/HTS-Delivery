//
//  OrderDetailViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 4/23/20.
//  Copyright © 2020 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import MapKit
import GLKit
import SOPullUpView
import Firebase
import FirebaseDatabase
import UBottomSheet

protocol UserLocationProtocol
{
  func  wasLocationUpdated(userLocation:CLLocation)
    
}

@available(iOS 10.0, *)
class OrderDetailViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var customerOrder:CustomerOrder?
    var response:MKDirections.Response?
    var locations=[CLLocationCoordinate2D]()
   //let pullUpController = SOPullUpControl()
    var eta=0
    var mkDir:MKDirections?
    var mostRecentLocation:CLLocation?
    var ref: DatabaseReference!
    var annotations = [MKAnnotation]()
    var overlay:MKOverlay?
    var userLocationProtocol:UserLocationProtocol?

   
    private lazy var locationManager: CLLocationManager = {
           let manager = CLLocationManager()
           manager.desiredAccuracy = kCLLocationAccuracyBest
           manager.delegate = self
           manager.requestWhenInUseAuthorization()
           //manager.allowsBackgroundLocationUpdates=true
           return manager
       }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate=self
        mapView.showsUserLocation=true
        
        ref = Database.database().reference()
        if let customerOrder = customerOrder, let courier=customerOrder.courier, let courierId=courier.courierId {
            
            ref.child("couriers/\(courierId)/info").observe(DataEventType.value, with: { [self] snapshot in
                let coordinates = snapshot.value as? [String:Any]
                if let coords = coordinates, let latitude = coords["latitude_courier"] as? String, let longitude=coords["longitude"] as? String
                {
                    
                        self.trackOrder(lat: latitude, long: longitude)
                    let userLocation = CLLocation(latitude: Double (latitude)!, longitude:Double(longitude)!)
                    self.userLocationProtocol?.wasLocationUpdated(userLocation: userLocation)
                   
                  
                }
            })
            
        }
       if
        
        let customerOrder = customerOrder, let order=customerOrder.order {
           
           title="Order # \(order.orderNumber)"
           
       }
        if (CLLocationManager.authorizationStatus() != .authorizedWhenInUse)
        {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        // parentViewController: main view controller that presents the bottom sheet
        // call this within viewWillLayoutSubViews to make sure view frame has measured correctly. see example projects.
        var vc:SOPullUpTableViewController!
        var vcPickup:SOPullUpTableViewControllerPickup
        let sheetCoordinator = UBottomSheetCoordinator(parent: self)
       
            if customerOrder?.courier != nil && customerOrder?.address != nil
            {
                 vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SOPullUpView") as! SOPullUpTableViewController
          
            vc.customerOrder=customerOrder
            vc.sheetCoordinator = sheetCoordinator
            userLocationProtocol=vc
            sheetCoordinator.addSheet(vc, to: self)
          
            }
            else
            {
                 vcPickup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SOPullUpViewPickup") as! SOPullUpTableViewControllerPickup
               
                   vcPickup.customerOrder=customerOrder
                  vcPickup.sheetCoordinator = sheetCoordinator
                  userLocationProtocol=vcPickup
                  sheetCoordinator.addSheet(vcPickup, to: self)
                
                  
                     
            }
       

      
      

       
       
      
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
       
    }
    
    func trackOrder(lat:String,long:String) -> Void {
           if let customerOrder = customerOrder {
              
               if let address=customerOrder.address
               {
                   if (customerOrder.order?.status != "delivered")
                   {
               let latLong = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                let latLongCustomer=CLLocationCoordinate2D(latitude: Double(address.latitude)!, longitude: Double(address.longitude)!)
                   if !locations.isEmpty
                   {
               locations[0]=latLong
               locations[1]=latLongCustomer
                   }else
                   {
                       locations.append(latLong)
                       locations.append(latLongCustomer)
                   }
               
               let courierPoint = MKPointAnnotation()
               courierPoint.coordinate=latLong
               let customerPoint = MKPointAnnotation()
               customerPoint.coordinate=latLongCustomer
               let source = MKPlacemark(coordinate: latLong)
              let destination = MKPlacemark(coordinate: latLongCustomer)
                  
                  let mkDRequest=MKDirections.Request()
                  mkDRequest.source=MKMapItem(placemark: source)
                  mkDRequest.destination=MKMapItem(placemark: destination)
                  
                mkDir = MKDirections(request: mkDRequest)
                mkDir!.calculate(completionHandler: { response, error in
                   if let response = response
                   
                   {
                       let region = MKCoordinateRegion.init(
                           center:self.getCenterCoordinates(locations: self.locations) ,latitudinalMeters: response.routes[0].distance,longitudinalMeters: response.routes[0].distance)
                       
                       print("\( round(response.routes[0].distance/1609.34*100)/100) \(Int(response.routes[0].expectedTravelTime/60)) \(response.routes[0].name)")
                      
                       DispatchQueue.main.async {
                         
                    
                           if !self.mapView.annotations.isEmpty
                           {
                               self.mapView.removeAnnotations(self.annotations)
                           }
                           
                           self.mapView.addAnnotation(courierPoint)
                           self.mapView.addAnnotation(customerPoint)
                           if self.overlay != nil
                           {
                               self.mapView.removeOverlay(self.overlay!)
                               
                           }
                           self.mapView.addOverlay(response.routes[0].polyline)
                           self.overlay=response.routes[0].polyline;
                           if !self.annotations.isEmpty
                           {
                               self.annotations[0]=courierPoint
                               self.annotations[1]=customerPoint
                           }
                           else
                           {
                               self.annotations.append(courierPoint)
                               self.annotations.append(customerPoint)
                           }
                           self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)

                       }
                     
                   
                      
                       self.response=response
                       
                   
                   }
                   
               })
                   }
       
           }
            else
            {
                if let customerLocation=mostRecentLocation, let seller=customerOrder.seller
                {
                    let lat=customerLocation.coordinate.latitude
                    let long=customerLocation.coordinate.longitude
                    let sellerLat=Double(seller.latitude!)
                    let sellerLong=Double(seller.longitude!)
                    let latLong = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(long))
                    let latLongSeller=CLLocationCoordinate2D(latitude: sellerLat!, longitude: sellerLong!)
                              /* if (locations.count<2)
                              {
                              locations.append(latLong)
                              locations.append(latLongSeller)
                               }*/
                    if !locations.isEmpty
                    {
                       locations[0]=latLong
                       locations[1]=latLongSeller
                    }else
                    {
                        locations.append(latLong)
                        locations.append(latLongSeller)
                    }
                              let courierPoint = MKPointAnnotation()
                              courierPoint.coordinate=latLong
                              let customerPoint = MKPointAnnotation()
                              customerPoint.coordinate=latLongSeller
                              let source = MKPlacemark(coordinate: latLong)
                             let destination = MKPlacemark(coordinate: latLongSeller)
                                 
                                 let mkDRequest=MKDirections.Request()
                                 mkDRequest.source=MKMapItem(placemark: source)
                                 mkDRequest.destination=MKMapItem(placemark: destination)
                                 
                               mkDir = MKDirections(request: mkDRequest)
                               mkDir!.calculate(completionHandler: { response, error in
                                  if let response = response
                                  
                                  {
                                      let region = MKCoordinateRegion.init(
                                          center:self.getCenterCoordinates(locations: self.locations) ,latitudinalMeters: response.routes[0].distance,longitudinalMeters: response.routes[0].distance)
                                      
                                      print("\( round(response.routes[0].distance/1609.34*100)/100) \(Int(response.routes[0].expectedTravelTime/60)) \(response.routes[0].name)")
                                     
                                  
                                      DispatchQueue.main.async {
                                          if !self.mapView.annotations.isEmpty
                                          {
                                              self.mapView.removeAnnotations(self.annotations)
                                          }
                                          self.mapView.addAnnotation(courierPoint)
                                          self.mapView.addAnnotation(customerPoint)
                                          if !self.annotations.isEmpty
                                          {
                                              self.annotations[0]=courierPoint
                                              self.annotations[1]=customerPoint
                                          }
                                          else
                                          {
                                              self.annotations.append(courierPoint)
                                              self.annotations.append(customerPoint)
                                          }
                   
                                         
                                          
                                          if self.overlay != nil
                                          {
                                              self.mapView.removeOverlay(self.overlay!)
                                              
                                          }
                                          self.mapView.addOverlay(response.routes[0].polyline)
                                          self.overlay=response.routes[0].polyline;
                                         
                                          self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                                      }
                                     
                                      self.response=response
                                      
                                  
                                  }
                                  
                              })
                
            }
            }
           }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getCenterCoordinates(locations:[CLLocationCoordinate2D]) -> CLLocationCoordinate2D {

            var x:Float = 0.0;
            var y:Float = 0.0;
            var z:Float = 0.0;

            for point in locations {

             let lat = GLKMathDegreesToRadians(Float(point.latitude));
             let long = GLKMathDegreesToRadians(Float(point.longitude));

                x += cos(lat) * cos(long);
                y += cos(lat) * sin(long);
                z += sin(lat);
            }
         x = x / Float(locations.count);
            y = y / Float(locations.count);
            z = z / Float(locations.count);

            let resultLong = atan2(y, x);
            let resultHyp = sqrt(x * x + y * y);
            let resultLat = atan2(z, resultHyp);

            let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))));

            return result;

        }

}
extension OrderDetailViewController:MKMapViewDelegate,CLLocationManagerDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        // 3
        if annotationView == nil {
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,
            blue: 0.4, alpha: 1)
            annotationView = pinView
        }
        if let  annotationView = annotationView
        {
             annotationView.annotation = annotation
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(displayP3Red: 255/255, green: 165/255, blue: 0, alpha: 1)
        renderer.lineWidth = 5
        
        return renderer
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
        return
    }
        self.mostRecentLocation=mostRecentLocation
        if customerOrder?.address==nil
        {
        trackOrder(lat:String(mostRecentLocation.coordinate.latitude), long: String(mostRecentLocation.coordinate.longitude))
            userLocationProtocol?.wasLocationUpdated(userLocation: mostRecentLocation)
        }
        
       
        
    }
    
    
    
}

