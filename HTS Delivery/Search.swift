/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
//  Search.swift
//  StoreSearch
//
//  Created by Moussa Hamet DEMBELE on 5/14/16.
//  Copyright © 2016 Moussa Hamet DEMBELE. All rights reserved.
//

import Foundation
import UIKit

class Search {
    var addons:[String]?
    var projectUrl = "https://www.htsdelivery.com/"
    var searchResults1 = [Product]()
    enum State
    {
        case notSearchedYet
        case loading
        case noResults
        case results([Product])
    }
    
    fileprivate(set) var state: State = .notSearchedYet
    enum Category: Int
    {
        case all = 0
        case music = 1
        case software = 2
        case eBooks = 3
        var entityName: String
        {
            switch self
            {
                
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .eBooks: return "ebook"
                
            }
        }
    }
    typealias SearchComplete = (Bool) -> Void
    fileprivate var dataTask: URLSessionDataTask? = nil
    
    func performSearchForText(_ text: String, completion: @escaping SearchComplete)
    {
        if !text.isEmpty
        {
            
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            state = .loading
            
            
            let url = urlWithSearchText()
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                self.state = .notSearchedYet
                var success = false
                if let error = error, error._code == -999
                {
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 ,
                    
                    let data = data, let dictionary = self.parseJSON(data)
                    
                {
                    var searchResults = self.parseDictionary(dictionary)
                    self.searchResults1 = self.parseDictionary(dictionary);
                    if searchResults.isEmpty
                    {
                        self.state = .noResults
                    }
                    else
                    {
                        
                        searchResults.sort(by: <)
                        self.state = .results(searchResults)
                    }
                    
                    success = true
                    
                    
                    
                    
                }
                
                
                DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success)
                }
                
            })
            
            dataTask?.resume()
            
        }
    }
    
    
    func urlWithSearchText() -> URL
        
    {
        
        
        let urlString = String(format: "https://www.htsdelivery.com/show_product_mobile.php")
        let url = URL(string: urlString)
        return url!
    }
    func parseJSON( _ data: Data)-> [String: AnyObject]?
    {
        
        do
        {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
        }
        catch
        {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parseDictionary(_ dictionary: [String: AnyObject])->[Product]
    {
        guard let array = dictionary["products"] as? [AnyObject]
            else
        {
            print("Exected 'results' array")
            return []
        }
        
        var searchResults = [Product]()
        for resultDict in array
        {
            if let resultDict = resultDict as? [String: AnyObject]
            {
                var searchResult: Product?
                searchResult = parseProduct(resultDict)
                if let result = searchResult
                {
                   
                    searchResults.append(result)
                    
                }
            }
            
            
        }
        
        
        return searchResults
    }
    func parseProduct(_ dictionary: [String: AnyObject]) -> Product
    {
        let itemId = dictionary["item_id"] as! String
        let description = dictionary["description"] as! String
        let designation = dictionary["designation"] as! String
        let price = dictionary["price"] as! String
        var imageUrl=""
        if let image=dictionary["image_url"] as? String
        {
            imageUrl=projectUrl+image
        }
        else
        {
            imageUrl="yassa.jpg"
        }
        
        let categoryId = dictionary["category_id"] as! String
        let categoryName = dictionary["category_name"] as! String
        //let addons = ["add something","add something","add something","add something","add something","add something","add something","add something","add something","add something"];
        let quantity = 0;
        let searchResult = Product(itemId: itemId,designation: designation,price: price,desc: description,imageUrl: imageUrl,quantity:quantity,addons:addons,categoryId:Int(categoryId)!,categoryName:categoryName,productExtras:nil,productSubCategories: nil,itemInstructions: "")

        
        return searchResult
    }
    
}
