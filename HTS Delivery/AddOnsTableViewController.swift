//
//  AddOnsTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 3/5/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class AddOnsTableViewController: UITableViewController {
    
   var tabBarControl:TabBarController?
    
    struct Addons {
        var addonItem:String?
        var isAdded = false
    }
    var itemDetails=ItemDetails()
    var productExtras=[ProductExtrasType.ProductExtras]()
    var productSubcategories=[ProductSubcategoryGroup.SubCategory]()
    var categories:[Category]?
    var details:ItemDetails?
    var indexPaths=[IndexPath]()
    var defaults = UserDefaults.standard
    var decodedCartItems = [Product]()
    var quantity:Int?
    var addedAddons = [[String:Any]]()
    var allAddons = [Addons]()
    var selectedItem: Product?
    var imageUrl:String?
    var numberOfRows=0
    var seller:Seller?
    var market:Market?
    let buttonsTintColor=UIColor(red: 255/255, green: 165/255, blue: 0, alpha: 1.0)
    let radioButtonImage=UIImage(named: "radio_button.png")
    let radioButtonCheckedImage=UIImage(named: "radio_button_checked.png")
    let checkBoxImage=UIImage(named: "check_box.png")
    let checkBoxCheckedImage=UIImage(named: "check_box_checked.png")
    var checkedCells=[String]()
    let shared=Shared()
    var itemInstructions=""
    var textView:UITextView?
    
    
    @IBAction func cancelAddingItem(_ sender: Any) {
        
       
      
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ItemAdded(_ sender: Any) {
        if areItemsFromSameSeller()
        {
        if self.quantity==nil
        {
            self.quantity = 1
        }
        update(product: selectedItem!, quantity:quantity! )
        dismiss(animated: true, completion: nil)
        }
        else
        {
            emptyCart()
            
        }
       
    }
    func update(product:Product,quantity:Int)
    {
        
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
            decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            product.quantity=quantity
            product.productSubCategories=productSubcategories
            product.productExtras=productExtras
            if let textView=textView, let text=textView.text,textView.textColor != UIColor.darkGray,!text.isEmpty
            {
                product.itemInstructions=text
            }
            decodedCartItems.append(product)
            let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: decodedCartItems)
            self.defaults.set(encodedData, forKey: "cartItems")
            self.defaults.synchronize()
            
        }
        else
        {
            
            product.quantity=quantity
            product.productSubCategories=productSubcategories
            product.productExtras=productExtras
            if let textView=textView, let text=textView.text, textView.textColor != UIColor.darkGray, !text.isEmpty
            {
                product.itemInstructions=text
            }
            decodedCartItems.append(product)
            let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: decodedCartItems)
            self.defaults.set(encodedData, forKey: "cartItems")
            self.defaults.synchronize()
            
            
        }
        if decodedCartItems.count==1
        {
            if let seller=seller
            {
            Seller.saveSeller(seller: seller)
            }
        }
        tabBarControl?.setCartBadgeValue()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarControl=(UIApplication.shared.delegate as! AppDelegate).getRootViewController()
        let addOnsHeaderCell = UINib(nibName: "AddOnsHeaderCell", bundle: nil)
        tableView.register(addOnsHeaderCell, forCellReuseIdentifier: "AddOnsHeaderCell")
        
        if let selectedItem=selectedItem
        {
            let itemId=selectedItem.itemId
            itemDetails.getItemDetails(itemId: itemId, completion: { [self] success,error in
            if(success)
            {
               
                
                DispatchQueue.main.async { [self] in
                    if let details = itemDetails.itemDetails
                    {
                        var i = 0;
                        for _ in details.productSubcategories {
                            
                            checkedCells.insert("cell_\(i+1)\(0)", at: i)
                            print("index \(i)")
                            print(checkedCells[i])
                            productSubcategories.insert(details.productSubcategories[i].subCategories[0], at:i)
                           
                            let indexPath=IndexPath(item: 0, section: i+1)
                           
                                indexPaths.insert(indexPath, at: i)
                                print("section \(indexPath.section)")
                          
                              
                            i=i+1;
                            
                           
                        }
                            
                           
                        self.details=details
                    }
                    tableView.reloadData()
                }
                
            }
            
            })
        }
        
        for i in 0 ..< 10
        {
            var addon = Addons()
            addon.addonItem = ("Item \(i)")
            allAddons.append(addon)
            
        }


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if let navigationC = presentedViewController as? UINavigationController
            {
                if let itemInstructionsViewController = navigationC.viewControllers.first as? ItemInstructionsViewController
                {
                    itemInstructions=itemInstructionsViewController.textView.text
                    print(itemInstructions)
                    
                }
                
            }
       
    }
    func areItemsFromSameSeller() -> Bool {
         var isFound=false
        if let categories=categories
        {
        if  let decoded = defaults.object(forKey: "cartItems") as? Data
        {
          let decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            if decodedCartItems.count>0
            {
              let  decodedCartItem=decodedCartItems[0]
                
                for category in categories {
                    if decodedCartItem.categoryId==category.categoryId
                    {
                        isFound=true
                        break
                    }
                }
                
            }
            else
            {
                isFound=true
                
            }
        }
            else
        {
            isFound=true
            }
        }
      return isFound
    }
    func emptyCart() -> Void {
        let actionNo=UIAlertAction(title: "NO", style: .cancel, handler: nil)
        let actionYes = UIAlertAction(title: "YES", style: .default, handler: { action in
          if   let decoded = self.defaults.object(forKey: "cartItems") as? Data
          {
            self.decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            self.decodedCartItems.removeAll()
            }
            let encodedData:Data = NSKeyedArchiver.archivedData(withRootObject: self.decodedCartItems)
            self.defaults.set(encodedData, forKey: "cartItems")
            self.defaults.synchronize()
            if self.quantity==nil
            {
                self.quantity = 1
            }
            self.update(product: self.selectedItem!, quantity:self.quantity! )
                DispatchQueue.main.async {
                     self.dismiss(animated: true, completion: nil)
                }
            
            
        })
        let altertController=UIAlertController(title: "Empty cart?", message: "Do you want to empty your cart?", preferredStyle: .alert)
        altertController.addAction(actionYes)
        altertController.addAction(actionNo)
        present(altertController, animated: true, completion: nil)
       
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let details = itemDetails.itemDetails
        {
            return details.productExtras.count+details.productSubcategories.count+2
        }
        else
        {
            return 2
        }
    }
   /* override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView()
        var headerTitle = UILabel()
        headerTitle.text="Title"
        headerView.addSubview(headerTitle)
        return headerView
    }*/
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle=""
        
       
        if section != 0 {
            if let details = details
                       {
                           if details.productSubcategories.count>0 && section<=details.productSubcategories.count
                           {
                              
                              
                                  if let title = String(htmlEncodedString: details.productSubcategories[section-1].name)
                               {
                                   headerTitle = title
                                }
                              
                              
                           }
                else if details.productExtras.count>0 && section<=details.productExtras.count+details.productSubcategories.count
                           {
                               if let title = String(htmlEncodedString: details.productExtras[section-1-details.productSubcategories.count].extraTypeName)
                               {
                               headerTitle = title
                               }
                               
                           }
                else
                {
                    headerTitle = "Add Instruction on your item"
                }
                       }
            else
            {
                headerTitle = "Add Instruction on your item"
                
            }
                 
             return headerTitle
        }
        else
        {
            return nil
        }
        
       
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        if(section==0)
        {
        if (selectedItem?.addons != nil)
        {
        return (selectedItem?.addons?.count)!
        }
        else
        {
            return 1
        }
        }
        else  if let details = details
        {
       
        
        switch section
        {
        case 1...details.productExtras.count+details.productSubcategories.count+1:
        if details.productSubcategories.count>0 && section<=details.productSubcategories.count {
                numberOfRows = details.productSubcategories[section-1].subCategories.count
            }
            else if details.productExtras.count>0 && section<=details.productSubcategories.count+details.productExtras.count
            {
    numberOfRows=details.productExtras[section-1-details.productSubcategories.count].extras.count
                
            }
            else
            {
                numberOfRows=1
                
            }
        
        default:
        numberOfRows = 0
                           
                           
        }
        
        
        
           
        }
        else
        {
            numberOfRows=1
        }
        return numberOfRows
    
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section==0 {
            return 320
        }
        else
        {
            return 50
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section==0)
        {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddOnsHeaderCell", for: indexPath) as! AddOnsHeaderCell
            cell.designation.text = String(htmlEncodedString: selectedItem!.designation)
            cell.desc.text = String(htmlEncodedString: selectedItem!.desc)
            cell.onChangeQuantityPressed =
                {
                   TableViewcell in
                   self.quantity = Int(cell.getQuantity.value)
            }
            if let url = URL(string: selectedItem!.imageUrl)
            {
            cell.imageViewHeaders.loadImageWithURL(url)
            }
            
            return cell
            
        }
        else if let details = details
        {
            var cell = UITableViewCell()
            
            var name=""
            
            if details.productSubcategories.count>0 && indexPath.section<=details.productSubcategories.count {
                
                cell =  tableView.dequeueReusableCell(withIdentifier: "addOnsCell", for: indexPath)
                let productSubCategory=details.productSubcategories[indexPath.section-1].subCategories[indexPath.row];
                if(Double(productSubCategory.price)!==0)
                {
                    if let subName = String(htmlEncodedString: details.productSubcategories[indexPath.section-1].subCategories[indexPath.row].name)
                    {
                        name = subName
                    }
                    
                }
                else
                {
                    if let market = market {
                        if Int(market.symbolPosition!)==0
                        {
                            if let subName=String(htmlEncodedString: productSubCategory.name)
                            {
                                name = "\(subName) + \(market.symbol!) \(productSubCategory.price)"
                            }
                        }
                        else
                        {
                            if let subName = String(htmlEncodedString: productSubCategory.name)
                            {
                                name = "\(subName) +  \(productSubCategory.price) \(market.symbol!)"
                            }
                            
                        }
                    }
                    
                }
                if  !checkedCells.contains("cell_\(indexPath.section)\(indexPath.row)")
                {
                    
                    if #available(iOS 13.0, *) {
                        let uiImageView=UIImageView(image: radioButtonImage?.withTintColor(buttonsTintColor))
                        uiImageView.tintColor = buttonsTintColor
                        cell.accessoryView=uiImageView
                        
                    }
                    else {
                        let uiImageView=UIImageView(image: radioButtonImage)
                        uiImageView.tintColor = buttonsTintColor
                        cell.accessoryView=uiImageView
                    }
                    
                    cell.accessoryView?.accessibilityIdentifier="cell_\(indexPath.section)\(indexPath.row)"
                    
                }
                else
                {
                    if #available(iOS 13.0, *) {
                        let uiImageView=UIImageView(image: radioButtonCheckedImage?.withTintColor(buttonsTintColor))
                        uiImageView.tintColor = buttonsTintColor
                        cell.accessoryView=uiImageView
                        
                    }
                    else {
                        let uiImageView=UIImageView(image: radioButtonCheckedImage)
                        uiImageView.tintColor = buttonsTintColor
                        cell.accessoryView=uiImageView
                    }
                    
                    
                    cell.accessoryView?.accessibilityIdentifier="cell_\(indexPath.section)\(indexPath.row)"
                    
                }
                
            }
            else if details.productExtras.count>0 && indexPath.section<=details.productExtras.count+details.productSubcategories.count
            {
                cell =  tableView.dequeueReusableCell(withIdentifier: "addOnsCell", for: indexPath)
                let productExtras=details.productExtras[indexPath.section-1-details.productSubcategories.count].extras[indexPath.row]
                if(Double(productExtras.price)!==0)
                {
                    if let extrasName=String(htmlEncodedString: productExtras.name)
                    {
                        name = extrasName
                    }
                }
                else
                {
                    if let market = market {
                        if Int(market.symbolPosition!)==0
                        {
                            if let extrasName=String(htmlEncodedString: productExtras.name)
                            {
                                name = "\(extrasName) + \(market.symbol!) \(productExtras.price)"
                            }
                        }
                        else
                        {
                            if let extrasName=String(htmlEncodedString: productExtras.name)
                            {
                                name = "\(extrasName) + \(productExtras.price) \(market.symbol!)"
                            }
                            
                        }
                        
                    }
                }
                
                if #available(iOS 13.0, *) {
                    cell.accessoryView=UIImageView(image: checkBoxImage?.withTintColor(buttonsTintColor))
                } else {
                    cell.accessoryView=UIImageView(image: checkBoxImage)
                }
                cell.accessoryView?.accessibilityIdentifier="checkBox_\(indexPath.section)\(indexPath.row)"
                
            }
            else
            {
                cell =  tableView.dequeueReusableCell(withIdentifier: "ItemInstructionsCell", for: indexPath)
               name="Add Special Instructions"
                
            }
            
            cell.textLabel?.text = name
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemInstructionsCell", for: indexPath)
            cell.textLabel?.text="Add Special Instructions"
            return cell
            
        }

        
        }
   override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if ( indexPath.section == 0 )
        {
            return nil

        }
        else
        {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cell=tableView.cellForRow(at: indexPath)
       
           if let details = itemDetails.itemDetails
        {
               
             if   indexPath.section<=details.productSubcategories.count+details.productExtras.count
               {
                   if details.productSubcategories.count>0 && indexPath.section<=details.productSubcategories.count {
                       let productSubCategory=details.productSubcategories[indexPath.section-1].subCategories[indexPath.row]
                       print("Identifer \(cell?.accessoryView?.accessibilityIdentifier)")
                       let cellAccessoryView=cell?.accessoryView
                       if let identifier=cell?.accessoryView?.accessibilityIdentifier
                       {
                           print(identifier)
                           if checkedCells.contains(identifier)
                           {
                               print("In")
                               return
                           }
                           
                           
                           
                           
                           let cellToChange=tableView.cellForRow(at:indexPaths[indexPath.section-1])
                           
                           
                           
                           
                           
                           
                           if #available(iOS 13.0, *) {
                               let uiImageView=UIImageView(image: radioButtonCheckedImage?.withTintColor(buttonsTintColor))
                               uiImageView.tintColor = buttonsTintColor
                               cell?.accessoryView=uiImageView
                               
                           }
                           else {
                               let uiImageView=UIImageView(image: radioButtonCheckedImage)
                               uiImageView.tintColor = buttonsTintColor
                               cell?.accessoryView=uiImageView
                           }
                           
                           
                           cell?.accessoryView?.accessibilityIdentifier="cell_\(indexPath.section)\(indexPath.row)"
                           print("New Cell Identifer \(cell?.accessoryView?.accessibilityIdentifier)")
                           
                           if #available(iOS 13.0, *) {
                               let uiImageView=UIImageView(image: radioButtonImage?.withTintColor(buttonsTintColor))
                               uiImageView.tintColor = buttonsTintColor
                               cellToChange?.accessoryView=uiImageView
                               
                           }
                           else {
                               let uiImageView=UIImageView(image: radioButtonImage)
                               uiImageView.tintColor = buttonsTintColor
                               cellToChange?.accessoryView=uiImageView
                           }
                           
                           
                           cellToChange?.accessoryView?.accessibilityIdentifier="cell_\(indexPaths[indexPath.section-1].section)\(indexPaths[indexPath.section-1].row)"
                           print("Cell to change \(indexPaths[indexPath.section-1].section)\(indexPaths[indexPath.section-1].row)")
                           
                           
                           
                           
                           indexPaths.remove(at: indexPath.section-1)
                           productSubcategories.remove(at: indexPath.section-1)
                           print("Removed cell \(checkedCells[indexPath.section-1])")
                           checkedCells.remove(at: indexPath.section-1)
                           
                           
                           indexPaths.insert(indexPath, at: indexPath.section-1)
                           productSubcategories.insert(productSubCategory, at: indexPath.section-1)
                           checkedCells.insert("cell_\(indexPath.section)\(indexPath.row)", at: indexPath.section-1)
                           print("Added cell \(checkedCells[indexPath.section-1])")
                           for checkedCell in checkedCells {
                               print("Currently Checked cells \(checkedCell)")
                           }
                           
                       }
                       
                       
                       
                       
                   }
                   else
                   {
                       let productExtra=details.productExtras[indexPath.section-1-details.productSubcategories.count].extras[indexPath.row]
                       if (cell?.accessoryView?.accessibilityIdentifier=="checkBox_\(indexPath.section)\(indexPath.row)")
                       {
                           let productExtrasType=details.productExtras[indexPath.section-1-details.productSubcategories.count]
                           var checkedBoxes=0
                           
                           if Int(productExtrasType.max)! > 0
                           {
                               for productExtra in productExtras {
                                   if productExtra.extraTypeId==productExtrasType.id
                                   {
                                       checkedBoxes=checkedBoxes+1
                                   }
                               }
                           }
                           
                           if Int(productExtrasType.max)! == 0
                           {
                               productExtras.append(productExtra)
                               if #available(iOS 13.0, *) {
                                   cell?.accessoryView=UIImageView(image: checkBoxCheckedImage?.withTintColor(buttonsTintColor))
                               } else {
                                   cell?.accessoryView=UIImageView(image: checkBoxCheckedImage)
                               }
                               cell?.accessoryView?.accessibilityIdentifier="checkBoxChecked_\(indexPath.section)\(indexPath.row)"
                           }
                           else if  checkedBoxes < Int(productExtrasType.max)!
                                        
                           {
                               productExtras.append(productExtra)
                               if #available(iOS 13.0, *) {
                                   cell?.accessoryView=UIImageView(image: checkBoxCheckedImage?.withTintColor(buttonsTintColor))
                               } else {
                                   cell?.accessoryView=UIImageView(image: checkBoxCheckedImage)
                               }
                               cell?.accessoryView?.accessibilityIdentifier="checkBoxChecked_\(indexPath.section)\(indexPath.row)"
                               
                           }
                           else
                           {
                               Shared.displayMessage(message: "You have reached the maximum number of selections", title: "Limit reached", viewController: self)
                               
                           }
                           
                           
                       }
                       else
                       {
                           
                           productExtras.remove(at: productExtras.firstIndex(of: productExtra)!)
                           if #available(iOS 13.0, *) {
                               cell?.accessoryView=UIImageView(image: checkBoxImage?.withTintColor(buttonsTintColor))
                           } else {
                               cell?.accessoryView=UIImageView(image: checkBoxImage)
                           }
                           cell?.accessoryView?.accessibilityIdentifier="checkBox_\(indexPath.section)\(indexPath.row)"
                           
                           
                       }
                       
                       
                   }
                   
               }
               else
               {
                shared.showItemInstructionsVC(presentingViewController: self)
                   
                   
               }
           }
            else
        {
                shared.showItemInstructionsVC(presentingViewController: self)
                
        }
        }
        
 

    

}
