//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 11/23/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

    import UIKit
    import Foundation
    
    class ProductsCollectionViewController: UICollectionViewController {
        fileprivate let reuseIdentifier = "FlickrCell"
        fileprivate let reuseIdentifierHeader="headerId"
        fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        fileprivate var cartItems = [Product]()
        var defaults = UserDefaults.standard
        var category=Category()
        var productsByCategory=[ProductByCategory]()
        var product=Product(itemId: "", designation: "", price: "", desc: "", imageUrl: "", quantity: 0, addons: nil, categoryId: 0, categoryName: "",productExtras: nil,productSubCategories: nil,itemInstructions: "")
        var resultByCategory = [Product]()
        var categories=[Category]()
        var products=[Product]()
        var seller:Seller?
        var item:Product?
        var market=Market()
        var hours=Hours()
        fileprivate let itemsPerRow: CGFloat = 2
        let search = Search()
        let shared=Shared()
        var downloadTask: URLSessionDownloadTask?
        var categotyTitle=""
        var selectedItem:Int?
        @IBAction func showCart(_ sender: Any) {
          if  let decoded = defaults.object(forKey: "cartItems") as? Data
          {
            let decodedCartItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            
            for item in decodedCartItems {
                print(item.imageUrl)
            }
          }
            else
          {
            print("Your cart is empty")
            }
            
        }
        
        
        
    }

    extension ProductsCollectionViewController : UITextFieldDelegate {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            shared.showLoadingView(view: view)
            let headerView = UINib(nibName: "HeaderViewNib", bundle: nil)
            collectionView.register(headerView, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerViewId")
             loadItems()
            title=categotyTitle
            let memoryCapacity = 500*1024*1024;
            let diskCapacity = memoryCapacity
            let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
            URLCache.shared = urlCache
           
           
            
                       
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier=="showAddons")
            {
               
                    if let navigationController = segue.destination as? UINavigationController
                        
                    {
                        if let addOnsTableViewController = navigationController.viewControllers.first as? AddOnsTableViewController
                        {
                        
                            addOnsTableViewController.selectedItem = self.item
                            addOnsTableViewController.categories=self.categories
                            addOnsTableViewController.seller=self.seller
                            addOnsTableViewController.market=market.market
                        }
                        
                   
                
                    
                }
            }
        }
        @objc func loadItems() -> Void {
           if let seller = seller
              {
                  product.getSellerProducts(sellerId: Int(seller.id!)!, completion: {success,error in
                      if(success)
                      {
                          self.market.getMarket(marketId: seller.marketId!, completion: {
                              success,error in
                              
                              if (!success)
                              {
                                return
                              }
                          })
                          
                          self.products=self.product.products
                          self.category.showCategories(sellerId: Int(seller.id!)!, completion:  { success,error in
                              if(success)
                              {
                                  print("categories \(self.category.categoryArray.count)")
                                  self.categories=self.category.categoryArray
                                  
                                  for category in self.categories {
                                      let productByCategory=ProductByCategory()
                                      
                                      productByCategory.categoryId=category.categoryId
                                          
                                      for product in self.products
                                          {
                                              if product.categoryId==category.categoryId
                                              {
                                                  productByCategory.products.append(product)
                                              }
                                          }
                                      self.productsByCategory.append(productByCategory)
                                      
                                  }
                                  
                                  
                                  DispatchQueue.main.async {
                                      self.collectionView.reloadData()
                                  }
                              }
                              
                          })
                          
                              DispatchQueue.main.async {
                                         self.collectionView.reloadData()
                                       self.shared.hideLoadingView()
                                         
                                     }
                      }
                      else if error != nil
                      {
                        DispatchQueue.main.async {
                            self.shared.hideLoadingView()
                            let button = self.shared.showReloadingView(view: self.view)
                            button.addTarget(self, action: #selector(self.loadItems), for: UIControl.Event.touchUpInside)
                        }
                      
                    }
                    else
                      {
                        DispatchQueue.main.async {
                            self.shared.hideLoadingView()
                            let button = self.shared.showReloadingView(view: self.view)
                            button.addTarget(self, action: #selector(self.loadItems), for: UIControl.Event.touchUpInside)
                            
                        }
                    }
                  })
               
              
              }
            else
           {
            let button = self.shared.showReloadingView(view: self.view)
                button.addTarget(self, action: #selector(self.loadItems), for: UIControl.Event.touchUpInside)
            
            }
           
        }
        
}
    // MARK: - UICollectionViewDataSource
    extension ProductsCollectionViewController {
        //1
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return productsByCategory.count+1
        }
        
        
        //2
        override func collectionView(_ collectionView: UICollectionView,
                                     numberOfItemsInSection section: Int) -> Int {
            switch section {
            case 0:
                return 0
            case 1...categories.count:
                return productsByCategory[section-1].products.count
            default:
                return 0
            }
        }
    
        
       
        
        //3
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCell
            if(indexPath.section != 0)
            {
            let searchResult = productsByCategory[indexPath.section-1].products[indexPath.row]
          
            
            if let url = URL(string: searchResult.imageUrl)
            {
               
                cell.downloadTask = cell.imageView.loadImageWithURL(url)
                
            }
        
        if let market=market.market, Int(market.symbolPosition!)==0
        {
            cell.price.text = "\(market.symbol!)\(searchResult.price)"
        }
        else if let  market=market.market, Int(market.symbolPosition!)==1
        {
            cell.price.text =  "\(searchResult.price) \(market.symbol!)"
        }
               
       cell.desc.text = String(htmlEncodedString: searchResult.designation) 
        print(searchResult.imageUrl+"\n")
        cell.onButtonPressed =
            {
                
                cell1 in
                self.selectedItem = indexPath.row
                self.item = self.productsByCategory[indexPath.section-1].products[indexPath.row]
                self.performSegue(withIdentifier: "showAddons", sender: self)
                
            }
            }
        
        cell.addToCart.center.x = cell.bounds.midX
        cell.desc.center.x = cell.bounds.midX
        cell.price.center.x = cell.bounds.midX
        cell.imageView.center.x = cell.bounds.midX
        cell.addToCart.layer.cornerRadius = 4
        cell.addToCart.clipsToBounds = true
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
         return cell
         
         }
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            switch (kind,indexPath.section) {
            case (UICollectionView.elementKindSectionHeader,0):
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerViewId", for: indexPath) as! HeaderView
                    headerView.layer.borderWidth=5
                    headerView.layer.borderColor=UIColor.white.cgColor
                    headerView.layer.cornerRadius=5
                    if let seller=seller
                    {
                        if let address = seller.address
                        {
                        headerView.address.text=String(htmlEncodedString: address) 
                        }
                        if let description=seller.sellerDescription
                        {
                        headerView.cuisine.text=String(htmlEncodedString: description)
                            
                        }
                        if let name=seller.name
                        {
                        headerView.name.text=String(htmlEncodedString: name)
                        }
                        if let image = seller.image, let imageUrl = URL(string:image)
                        {
                        headerView.imageView.loadImageWithURL(imageUrl)
                        }
                        if let logo = seller.logo, let logoUrl = URL(string:logo)
                        {
                        headerView.logoImageView.loadImageWithURL(logoUrl)
                        }
                        hours.readHours(sellerId: seller.id!, completion: {
                            success,error in
                            
                            if (success)
                            {
                                if let hours=self.hours.hours
                                {
                                    if (hours.status=="open")
                                    {
                                    headerView.statusLabel.text="OPEN NOW"
                                    }
                                    else
                                    {
                                    headerView.statusLabel.text="CLOSED"
                                        
                                    }
                                    headerView.hoursLabel.text="\(hours.currentDay) \(hours.open) - \(hours.close)"
                                    
                                }
                            }
                            
                        })
                        
                        
                    }
                    return headerView
            case (UICollectionView.elementKindSectionHeader,1...categories.count):
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! HeaderCell
                    headerView.headerLabel.text=categories[indexPath.section-1].categoryName
                    return headerView
            default:
                assert(false, "Unexpected element kind")
                return UICollectionReusableView()
                }
                
           
            }
        
    }
   extension ProductsCollectionViewController : UICollectionViewDelegateFlowLayout {
        //1
        
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                                   sizeForItemAt indexPath: IndexPath) -> CGSize {
            //2
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: 250.0)
        }
        
        //3
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                                   insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
        
        // 4
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                                   minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return sectionInsets.left
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section==0
        {
            return CGSize(width: view.frame.width-(sectionInsets.left*2), height: 460)
        }
        else
        {
        return CGSize(width: view.frame.width, height: 50)
            
        }
    }
    
    }
extension UIImageView
{
    func loadImageWithURL(_ url:URL) -> URLSessionDownloadTask
    {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
            
            if error == nil, let url = url,
                
                let data = try? Data(contentsOf: url), let image = UIImage(data: data)
            {
                DispatchQueue.main.async
                    {
                        if let strongSelf = self
                        {
                            
                            strongSelf.image = image
                            
                           
                        }
                }
            }
            
        })
        downloadTask.resume()
        return downloadTask
}
}


       




