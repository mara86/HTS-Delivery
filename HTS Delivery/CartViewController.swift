//
//  CartViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/24/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit
import SafariServices




class CartViewController: UIViewController,PaymentTypesDelegate {
    
    
    
    func didRequestPayWithNewCard(paymentMethodNonce: String, completionHandler: @escaping (Error?) -> Void) {
        postNonceToServer(paymentMethodNonce: paymentMethodNonce,squareCustomerId: nil) { (transactionID, errorDescription) in
                guard let errorDescription = errorDescription else {
                    self.emptyCart()
                    DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    self.shared.showTaskCompletedView(view: self.view)
                    self.paymentTypesViewController!.dismiss(animated: true)
                   
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
                
                
                    completionHandler(nil)
                    return
                }

                // Pass error description
                self.shared.hideLoadingView()
                let error = NSError(domain: "com.htsdelivery.www", code: 0, userInfo:[NSLocalizedDescriptionKey : errorDescription])
            DispatchQueue.main.async {
                completionHandler(error)
            }
               
            }
    }
    
    
  
    func didRequestPayWithSavedCard(card: Card) {
        
        postNonceToServer(paymentMethodNonce: card.cardId,squareCustomerId: card.customerId) { (transactionID, errorDescription) in
                guard let errorDescription = errorDescription else {
                    self.emptyCart()
                    DispatchQueue.main.async {
                    self.shared.hideLoadingView()
                    self.shared.showTaskCompletedView(view: self.view)
                    self.paymentTypesViewController?.dismiss(animated: true)
                    
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOrder"), object: nil)
                
                
                  
                    return
                }

                // Pass error description
                self.shared.hideLoadingView()
                let error = NSError(domain: "com.htsdelivery.www", code: 0, userInfo:[NSLocalizedDescriptionKey : errorDescription])
            DispatchQueue.main.async {
               
            }
               
            }
        
    }
    
    var clientTokenToUse: String?
    var defaults = UserDefaults.standard
    var decodedCartItems = [Product]()
    var downloadTask: URLSessionDownloadTask?
    var dataToSend = [String:Any?]()
    var cartDictionary = [String:Any]()
    typealias TokenWithError = (String?,Error?)->Void
    var productExtras=[ProductExtrasType.ProductExtras]()
    var productSubcategories=[ProductSubcategoryGroup.SubCategory]()
    
    var myString : String?
    var rawData: Data?
    var tokenError:Error?
    var dictionaries = [[String:Any]]()
    var amount:Double = 0.0
    var subtotal:Double = 0.0
    var tipValue=0.00
    var tax=0.00
    var customer:Customer?
    var orderInfo:OrderInfo?
    var shared=Shared()
    var tabBarControl:TabBarController?
    var emptyCartView:UIView?
    var imageView:UIImageView?
    var emptyCartLabel:UILabel?
    var customTipTextField:UITextField?
    var customTipValue=0.00
    var deliveryFee=0.00
    var market=Market()
    let order=Order()
    var isCustomTipSet=false
    let urlToken = "https://www.htsdelivery.com/product.php"
    let url = "https://www.htsdelivery.com/api/order/placeOrder.php"
    var card:Card?
    var paymentTypesViewController:PaymentTypesViewController?
    @IBOutlet weak var tipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var cartFooterView: UIView!
    @IBOutlet weak var cartTableView: UITableView!
    @IBAction func tipSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex==3
        {
            customTip()
        }
        updateTipValue()
    }
    
    @IBAction func processPayment(_ sender: Any) {
        if let _ = Customer.retrieveCustomer(),Customer.retrieveCustomerStatus()
        {
        if let market=market.market,let marketId=market.marketId,Int(marketId)!==1
        {
    
            
            presentPaymentTypes()
        
        }
        else
        {
            self.shared.showLoadingView(view: self.view)
            order.placeOrderCash(subTotal: subtotal, tipValue: tipValue, deliveryFee: deliveryFee,tax: tax, completion: {
                success,error in
               
                DispatchQueue.main.async {
                    
                }
               
                if success
                {
                    self.emptyCart()
                    DispatchQueue.main.async {
                        self.shared.hideLoadingView()
                        self.shared.showTaskCompletedView(view: self.view)
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
        else
        {
            shared.showSign(presentingViewController: self)
        }
        
        
    }
    
    func presentPaymentTypes()
    {
     
        paymentTypesViewController=(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentTypesViewController") as! PaymentTypesViewController)
        
        paymentTypesViewController?.paymentTypesDelegate=self
        
        if let paymentTypesViewController = paymentTypesViewController
        {
            
            present(paymentTypesViewController, animated: true)
        }
      
   }
    
   

   
    
    override func viewDidAppear(_ animated: Bool) {
        
        cartTableView.estimatedRowHeight = 100
        cartTableView.rowHeight=UITableView.automaticDimension
       
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            if(decodedCartItems.count>0)
            {
                hideEmptyCartView()
                reloadData()
            }
            else
            {
                showEmptyCartView()
            }
        }
        if let seller = Seller.retrieveSeller()
        {
            self.market.getMarket(marketId: seller.marketId!, completion: {
            success,error in
            
            if (!success)
            {
              return
            }
                DispatchQueue.main.async {
                    self.reloadData()
                    self.cartTableView.reloadData()
                    self.updateTipValue()
                }
               
                
        })
        }
       
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        shared.hideTaskCompletedView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let seller = Seller.retrieveSeller()
        {
            self.market.getMarket(marketId: seller.marketId!, completion: {
            success,error in
            
            if (!success)
            {
              return
            }
                if let orderInfo=OrderInfo.getOrderInfo(),orderInfo.orderType==1 {
                    self.deliveryFee=seller.deliveryFee!
                    
                }
                
                self.reloadData()
                self.cartTableView.reloadData()
                self.updateTipValue()
               
                
        })
        }
      
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "orderTypeUpdated"), object: nil)
        orderInfo=OrderInfo.getOrderInfo()
        tabBarControl=(UIApplication.shared.delegate as! AppDelegate).getRootViewController()
        title = "Cart"
        checkOutButton.center.x = cartFooterView.bounds.midX
        checkOutButton.center.y = cartFooterView.bounds.midY
        checkOutButton.layer.cornerRadius=4
        checkOutButton.clipsToBounds=true
        cartFooterView.clipsToBounds=true
        cartTableView.dataSource=self
        cartTableView.delegate=self
        cartTableView.estimatedRowHeight = 100
        cartTableView.rowHeight=UITableView.automaticDimension
        cartTableView.tableFooterView = UIView()
        let cellNib = UINib(nibName: "CartCell", bundle: nil)
        let cellFooterNib = UINib(nibName: "CartFooterCell", bundle: nil)
        let cellEmptyCart = UINib(nibName: "EmptyCartCell", bundle: nil)
        let cellFooterWithFeeNib = UINib(nibName: "CartFooterCellWithFee", bundle: nil)
        cartTableView.register(cellEmptyCart, forCellReuseIdentifier: "EmptyCartCell")
        cartTableView.register(cellNib, forCellReuseIdentifier: "CartCell")
        cartTableView.register(cellFooterNib, forCellReuseIdentifier: "CartFooterCell")
        cartTableView.register(cellFooterWithFeeNib, forCellReuseIdentifier: "CartFooterCellWithFee")
        emptyCartView=UIView(frame: view.frame)
        imageView=UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            if(decodedCartItems.count>0)
            {
                hideEmptyCartView()
                reloadData()
               
            }
            else
            {
                showEmptyCartView()
            }
            
           
        }
        
        
        if let decodedCustomer = defaults.object(forKey: "customerInfo") as? Data
        {
            customer = NSKeyedUnarchiver.unarchiveObject(with: decodedCustomer) as? Customer
        }
        shared.loadViewController(viewController: self, width: view.frame.width)
                // Do any additional setup after loading the view.
       
    
        
    }
    func customTip() -> Void {
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            if let customTip=self.customTipTextField,let value = customTip.text
            {
                if let doubleValue = Double(value), doubleValue>=0
                {
                self.tipValue=doubleValue
                    if let market=self.market.market,let sympbolPosition=market.symbolPosition,Int(sympbolPosition)==0
                    {
                        self.tipLabel.text="\(market.symbol!)\(doubleValue)"
                    }
                    else if let market=self.market.market,let sympbolPosition=market.symbolPosition,Int(sympbolPosition)==1
                    {
                        self.tipLabel.text="\(doubleValue) \(market.symbol!)"
                        
                    }
                self.customTipValue=doubleValue
                self.isCustomTipSet=true
                }
                else
                {
                print("Provide a numeric value")
                    
                }
                
                
            }
            
            
        })
        let controller = UIAlertController(title: "Tip", message: "Please enter the tip amount.", preferredStyle: .alert)
        controller.addTextField(configurationHandler: {textField in
            self.customTipTextField=textField
        })
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
   @objc func reloadData() -> Void {
        updateTotal()
        if decodedCartItems.count==0
        {
            showEmptyCartView()
        }
        let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
        defaults.set(encodedData, forKey: "cartItems")
        defaults.synchronize()
        cartTableView.reloadData()
        tabBarControl?.setCartBadgeValue()
      
    }
    
    func updateTotal() -> Void {
        subtotal=0.00
        for decodedItem in decodedCartItems
               {
                   subtotal = subtotal+Double(decodedItem.price)!*Double(decodedItem.quantity)
                   for subCategory in decodedItem.productSubCategories {
                       subtotal+=Double(subCategory.price)!*Double(decodedItem.quantity)
                                  }
                                  
                                  for extra in decodedItem.productExtras {
                                   subtotal+=Double(extra.price)!*Double(decodedItem.quantity)
                                  }
               }
        
        if let market=self.market.market
        {
            if let taxRate=market.tax
            {
                tax=(subtotal*round((Double(taxRate)!/100)*100)/100)
            }
        }
       
    }
    
    func emptyCart() -> Void {
        if  decodedCartItems.count>0
        {
        decodedCartItems.removeAll()
        let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
        self.defaults.set(encodedData, forKey: "cartItems")
        self.defaults.synchronize()
        
            DispatchQueue.main.async {
               
                self.cartTableView.reloadData()
                self.tabBarControl?.setCartBadgeValue()
            }
        
        }
    }
    func postNonceToServer(paymentMethodNonce: String,squareCustomerId:String?, completion: @escaping (String?, String?) -> Void)  {
        if let seller=Seller.retrieveSeller() {
            var s=[String:Any]()
            s["id"]=seller.id
            s["phone"]=seller.phone
            s["name"]=seller.name
            s["address"]=seller.address
            s["delivery_fee"]=seller.deliveryFee
            s["market_id"]=seller.marketId
            cartDictionary["seller"]=s;
        }
        else
        {
           
            return
        }
        if let customer = Customer.retrieveCustomer()
        {
            var c=[String:Any]()
            c["email"]=customer.email
            cartDictionary["customer_id"]=customer.customerId
            cartDictionary["token"]=paymentMethodNonce
            cartDictionary["customer"]=c
            cartDictionary["square_customer_id"]=squareCustomerId
            
        }
        else
        {
            return
        }
        if  let orderInfo = OrderInfo.getOrderInfo(),orderInfo.orderType==1
        {
            cartDictionary["order_type"]=1
            cartDictionary["delivery_instructions"]=orderInfo.deliveryInstructions
            cartDictionary["address_id"]=orderInfo.address!.id
            cartDictionary["address"]=orderInfo.address!.completeAddress
        }
        else
        {
        cartDictionary["order_type"]=0
        cartDictionary["delivery_instructions"]=nil
        cartDictionary["address_id"]=nil
        }
        cartDictionary["tip"]="\(round(tipValue*100)/100)"
        var items=[Any]()
        if(!dictionaries.isEmpty)
        {
            dictionaries.removeAll()
            
        }
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            for decodedItem in decodedCartItems {
                var item=[String:Any]()
                 var subs=[Any]()
                var extras=[Any]()
                item["id"]=decodedItem.itemId
                item["name"]=decodedItem.designation
                item["price"]=decodedItem.price
                item["item_instruction"]=decodedItem.itemInstructions
                for ps in decodedItem.productSubCategories {
                    var sub=[String:Any]()
                    sub["id"]=ps.id
                    sub["price"]=ps.price
                    sub["name"]=ps.name
                    subs.append(sub)
                }
                for  ext in decodedItem.productExtras {
                    var extra=[String:Any]()
                    extra["id"]=ext.id
                    extra["price"]=ext.price
                    extra["name"]=ext.name
                    extras.append(extra)
                }
                item["item_sub_categories"]=subs
                item["item_extras"]=extras
                item["quantity"]=decodedItem.quantity
                items.append(item)
            }
            
            cartDictionary["order_total"]="\(round((subtotal+tax+tipValue+deliveryFee)*100)/100)"
            cartDictionary["items"]=items
            print(cartDictionary)
            
           
            
        }
        
        ChargeApi.processPayment(cartDictionary) { (transactionID, errorDescription) in
            completion(transactionID,errorDescription)
        }
        
    }
    
    func fetchClientToken(completion:@escaping TokenWithError) {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: urlToken)!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            if let data = data
            {
                
                let clientToken = String(data: data, encoding: String.Encoding.utf8)
                self.clientTokenToUse = clientToken!
                completion(clientToken,nil)
                
            }
            else if let error = error
            {
                completion(nil,error)
                
            }
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateTipValue() -> Void {
        
       
       
        tipSegmentedControl.setTitle("10%", forSegmentAt: 0)
        tipSegmentedControl.setTitle("15%", forSegmentAt: 1)
        tipSegmentedControl.setTitle("20%", forSegmentAt: 2)
        tipSegmentedControl.setTitle("Custom", forSegmentAt: 3)
        if let market=market.market,let symbolPosition=market.symbolPosition, Int(symbolPosition)==0
        {
            switch tipSegmentedControl.selectedSegmentIndex {
            case 0:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.10)
                tipLabel.text="\(market.symbol!)\(tipValue)"
            case 1:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.15)
                tipLabel.text="\(market.symbol!)\(tipValue)"
            case 2:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.20)
                tipLabel.text="\(market.symbol!)\(tipValue)"
            case 3:
               
                tipValue=customTipValue
                tipLabel.text="\(market.symbol!)\(tipValue)"
            default:
            tipLabel.text="\(market.symbol!)\(tipValue)"
            }
            
        }
        else if let market=market.market,let symbolPosition=market.symbolPosition, Int(symbolPosition)==1
        {
            switch tipSegmentedControl.selectedSegmentIndex {
            case 0:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.10)
                tipLabel.text="\(tipValue) \(market.symbol!)"
            case 1:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.15)
                tipLabel.text="\(tipValue) \(market.symbol!)"
            case 2:
                tipValue=getSubTotal(tax: Double(market.tax!)!, tipRate: 0.20)
                tipLabel.text="\(tipValue) \(market.symbol!)"
            case 3:
                
                tipValue=customTipValue
                tipLabel.text="\(tipValue) \(market.symbol!)"
            default:
            tipLabel.text="\(tipValue) \(market.symbol!)"
            }
            
        }
       
       
        
    }
    func showEmptyCartView() -> Void {
    if let emptyCartView=emptyCartView, let imageView=imageView
    {
      imageView.image=UIImage(named: "cart.png")
      imageView.center=emptyCartView.center
      emptyCartView.addSubview(imageView)
      emptyCartLabel=UILabel(frame: CGRect(x: view.frame.midX-75, y: view.frame.midY+imageView.frame.height, width: 150, height: 30))
      if let emptyCartLabel=emptyCartLabel
      {
      emptyCartLabel.text="Your cart is empty."
      emptyCartLabel.textColor = UIColor.black.withAlphaComponent(0.5)
      emptyCartView.addSubview(emptyCartLabel)
      }
      emptyCartView.backgroundColor = .white
      view.addSubview(emptyCartView)
    }
    }
    func hideEmptyCartView() -> Void {
        if let emptyCartView=emptyCartView, let emptyCartLabel=emptyCartLabel, let imageView=imageView
        {
            
            imageView.removeFromSuperview()
            emptyCartLabel.removeFromSuperview()
            emptyCartView.removeFromSuperview()
        }
        
    }

}
extension CartViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0
        {
        return 1
        
        }
        else
        {
            if(decodedCartItems.count>0)
            {
            return decodedCartItems.count+1
            }
            else
            
            {
                return 1
            }
            
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if decodedCartItems.count>0
        {
        return 2
        }
        else
        {
         return 1
        }
    }
    
    
}
extension CartViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var itemsDetails=""
        var price=0.00
        if(decodedCartItems.count==0)
        {
            checkOutButton.isEnabled = false
            checkOutButton.isHidden = true
            tipSegmentedControl.isHidden=true
            tipLabel.isHidden=true
            tipTitleLabel.isHidden=true
            tableView.rowHeight=view.frame.height
            let cellEmptyCart = tableView.dequeueReusableCell(withIdentifier: "EmptyCartCell", for: indexPath)
            return cellEmptyCart
        }
        else
        {
            checkOutButton.isEnabled = true
            checkOutButton.isHidden = false
            tipSegmentedControl.isHidden=false
            tipLabel.isHidden=false
            tipTitleLabel.isHidden=false
           
            if indexPath.section==0 {
               
            let cell=tableView.dequeueReusableCell(withIdentifier: "orderTypeCell") as! OrderTypeCell
                if let orderInfo=OrderInfo.getOrderInfo(),orderInfo.orderType==1 {
                    cell.orderType.text="Delivery to:"
                    cell.address.text=String(htmlEncodedString: orderInfo.address!.completeAddress)
                }
                else
                {
                    cell.orderType.text="Pickup from:"
                    if let address=Seller.retrieveSeller()?.address
                    {
                    cell.address.text=String(htmlEncodedString:address)
                    }
                    
                }
                return cell
            }
            else
         {
                
        if (indexPath.row < decodedCartItems.count)
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let cartResult = decodedCartItems[indexPath.row]
            if cartResult.productSubCategories.count>0
            {
                
                for productSubcategory in  cartResult.productSubCategories {
                    if(cartResult.productSubCategories.firstIndex(of: productSubcategory) != cartResult.productSubCategories.count-1)
                    {
                    if let name=String(htmlEncodedString: productSubcategory.name)
                        {
                    itemsDetails+=name+", "
                    }
                    }
                    else
                    {
                    if let name = String(htmlEncodedString: productSubcategory.name)
                        {
                         itemsDetails+=name
                        }
                        
                    }
                    price+=Double(productSubcategory.price)!
                }
                
            }
            
            if(cartResult.productExtras.count>0)
            {
                if(cartResult.productSubCategories.count>0)
                {
                    itemsDetails+=", "
                }
                
                for productExtras in cartResult.productExtras {
                    if(cartResult.productExtras.firstIndex(of: productExtras) != cartResult.productExtras.count-1)
                    {
                        if let name=String(htmlEncodedString: productExtras.name)
                        {
                    itemsDetails+=name+", "
                        }
                    }
                    else
                    {
                        if let name = String(htmlEncodedString: productExtras.name)
                        {
                    itemsDetails+=name
                        }
                        
                    }
                    price+=Double(productExtras.price)!
                }
                
            }
        price+=Double(cartResult.price)!
        price=round(price*100)/100
        cell.itemDetails.text=itemsDetails
        cell.itemImageView.layer.cornerRadius = 4
        cell.itemImageView.clipsToBounds = true
        cell.quantity.text = "\(cartResult.quantity)"
        cell.itemName.text = String(htmlEncodedString: cartResult.designation)
            if let market = market.market, let symbolPosition=market.symbolPosition, Int(symbolPosition)==0
            {
                cell.price.text = "\(market.symbol!)\(price)"
            }
            else if let market = market.market, let symbolPosition=market.symbolPosition, Int(symbolPosition)==1
            {
                cell.price.text = "\(price) \(market.symbol!)"
            }
        if let url = URL(string: cartResult.imageUrl)
        {
            
            cell.itemImageView.loadImageWithURL(url)
        }
        cell.onButtonMinusPressed = {
            cell in
            if (cartResult.quantity > 1 )
            {
                
                cartResult.quantity = cartResult.quantity - 1
                self.reloadData()
                self.updateTipValue()
                
            }
            
            
        }
        cell.onButtonPlusPressed = {
            cell in
            if (cartResult.quantity < 10)
            {
                cartResult.quantity = cartResult.quantity + 1
                self.reloadData()
                self.updateTipValue()
                
            }
            
            
        }
        cell.onButtonDeletePressed =
            {
                cell in
                self.decodedCartItems.remove(at: indexPath.row)
                self.reloadData()
                self.updateTipValue()
        }

         return cell
        }
        else
        {
            if  let orderInfo = OrderInfo.getOrderInfo(),orderInfo.orderType==1
            {
          let  cell = tableView.dequeueReusableCell(withIdentifier: "CartFooterCellWithFee", for: indexPath) as! CartFooterCellWithFee
                if let market=market.market,let symbolPosition=market.symbolPosition,Int(symbolPosition)==0
                {
                if let seller=Seller.retrieveSeller(), let deliveryFee=seller.deliveryFee
                {
                    self.deliveryFee=deliveryFee
                    cell.deliveryFee.text="\(market.symbol!)\(round(deliveryFee*100)/100)"
                   
                }
            cell.subtotal.text = "\(market.symbol!)\(round(subtotal*100)/100)"
            cell.tax.text = "\(market.symbol!)\(round((tax)*100)/100)"
            cell.total.text = "\(market.symbol!)\(round((subtotal+tax+deliveryFee)*100)/100)"
                }
                else  if let market=market.market,let symbolPosition=market.symbolPosition,Int(symbolPosition)==1
                {
                    if let seller=Seller.retrieveSeller(), let deliveryFee=seller.deliveryFee
                    {
                        self.deliveryFee=deliveryFee
                        cell.deliveryFee.text="\(round(deliveryFee*100)/100) \(market.symbol!)"
                       
                    }
                cell.subtotal.text = "\(round(subtotal*100)/100) \(market.symbol!)"
                cell.tax.text = "\(round((tax)*100)/100) \(market.symbol!)"
                cell.total.text = "\(round((subtotal+tax+deliveryFee)*100)/100) \(market.symbol!)"
                    
                    
                }
            
           
            return cell
            }
           else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CartFooterCell", for: indexPath) as! CartFooterCell
                if let market=market.market,let symbolPosition=market.symbolPosition,Int(symbolPosition)==0
                {
                    cell.subtotal.text = "\(market.symbol!)\(round(subtotal*100)/100)"
                cell.tax.text = "\(market.symbol!)\(round((tax)*100)/100)"
                cell.total.text = "\(market.symbol!)\(round((subtotal+tax)*100)/100)"
                }
                else if let market=market.market,let symbolPosition=market.symbolPosition,Int(symbolPosition)==1
                {
                    cell.subtotal.text = "\(round(subtotal*100)/100) \(market.symbol!)"
                cell.tax.text = "\(round((tax)*100)/100) \(market.symbol!)"
                cell.total.text = "\(round((subtotal+tax)*100)/100) \(market.symbol!)"
                    
                }
               
               
                return cell
                
            }
           
        }
            
        }
            
        }
    
        
    }
    func getSubTotal(tax:Double,tipRate:Double)->Double
    {
        let taxValue=subtotal*tax/100
        let subTotal = round((subtotal+taxValue+deliveryFee)*tipRate*100)/100
        return subTotal
    }
    
}

extension CartViewController:SFSafariViewControllerDelegate
{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let invoiceUrl = order.invoiceUrl
        {
        let invoiceUrlArray = invoiceUrl.pathComponents.split(separator: "/")
        let invoiceUrlSubArray=invoiceUrlArray[invoiceUrlArray.count-1]
        let order=Order()
            let transactionId=invoiceUrlSubArray[invoiceUrlSubArray.count]
            
            order.getOrderByTransactionId(transactionId: transactionId , completion: {
                success, error in
                
                if success
                {
                    self.emptyCart()
                    DispatchQueue.main.async {
                        self.shared.showTaskCompletedView(view: self.view)
                    }
              
                    
                }
            })
           
        }
    }

}

