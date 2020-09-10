//
//  ViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit

struct SearchOption {
    var size: Int
    var sort: String
    var page: Int
    var query: String
    
    init() {
        size = 10
        sort = "accuracy"
        page = 1
        query = ""
    }
}

class ViewController: UIViewController, UISearchBarDelegate {
    
    var apiReulstDocument: NSArray = []
    var searchOption = SearchOption()
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query: String = searchBar.searchTextField.text!
        print(query)
        
        searchOption.query = query
        
        let apiRequest = APIResquest()
        
        apiRequest.sendRequest(searchOption) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "error")
                return
            }
            
            print(responseObject)
//            print(type(of: responseObject))
            
//            print(responseObject["meta"]!["pageable_count"]!)
            // print(responseObject.value( forKeyPath: "meta.pageable_count" )!)
            self.apiReulstDocument = responseObject.value(forKeyPath: "documents")! as! NSArray
            
            // 개수 가져오기
            
            self.tmp()
        }
    }
    
    func tmp() {

        print(apiReulstDocument.count)
        print(type(of: apiReulstDocument[0]))
        
        for i in 0 ..< apiReulstDocument.count {
            print((apiReulstDocument[i] as! NSDictionary).value(forKey: "thumbnail_url") as! String)
        }
    }

    
}

