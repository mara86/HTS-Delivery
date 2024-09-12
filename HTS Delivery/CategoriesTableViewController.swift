//
//  CategoriesTableViewController.swift
//  FlickrSearch
//
//  Created by Moussa Hamet DEMBELE on 2/28/17.
//  Copyright © 2017 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
   
   var  resultByCategory = [Product]()
   var categories = [Product]()
   var search = Search()
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = (tableView.center)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.black
        tableView.addSubview(activityIndicator)
        search.performSearchForText("some text", completion:  { success in
            if success
            {
                activityIndicator.stopAnimating()
                print("Found \(self.search.searchResults1.count)")
                
                    for i in 0..<self.search.searchResults1.count
                    {
                        if(self.categories.count==0)
                        {
                      self.categories.append(self.search.searchResults1[i])
                        }
                        else
                        {
                            var isFound = false
                            let valueToSearch = self.search.searchResults1[i]
                            for j in 0..<self.categories.count
                            {
                                if (valueToSearch.categoryId == self.categories[j].categoryId)
                                {
                                    isFound = true
                                    
                                }
                                
                            }
                            if(!isFound)
                            {
                                self.categories.append(self.search.searchResults1[i])
                            }
                        }
                       
                        
                }

                 print("Categories \(self.categories.count)")
                self.tableView.reloadData()
                
                
                
            }
            else
            {
                let myAlert =  UIAlertController(title: "Error", message: "Please check your connection", preferredStyle: UIAlertController.Style.alert)
                let myAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                myAlert.addAction(myAction)
                self.present(myAlert, animated: true, completion: {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                })
                
                
            }
            
        })

        title = "Categories"
        
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="showDetail")
        {
            
           if  let indexPath = tableView.indexPathForSelectedRow
           {
            let itemsInCategory = segue.destination as? ProductsCollectionViewController
            
            itemsInCategory?.resultByCategory = getProductsByCategory(category: categories[indexPath.row])
            itemsInCategory?.categotyTitle = categories[indexPath.row].categoryName!
            
            
           
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = categories[indexPath.row].categoryName

        return cell
    }
    
    func getProductsByCategory(category:Product)->[Product]
        
    {
        resultByCategory.removeAll()
        for i in 0..<search.searchResults1.count
        {
            if (category.categoryId==search.searchResults1[i].categoryId)
            {
                resultByCategory.append(search.searchResults1[i])
            }
        }
        
        return resultByCategory
        
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
