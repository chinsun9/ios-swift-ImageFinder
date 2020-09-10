//
//  ViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    
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
        
        let apiRequest = APIResquest()
        
        apiRequest.sendRequest(query) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "error")
                return
            }
            
            print(responseObject)
        }
    }

    
}

