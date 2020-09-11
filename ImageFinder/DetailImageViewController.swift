//
//  DetailImageViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/11.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit
import WebKit


class DetailImageViewController: UIViewController {

    var document: NSDictionary = [:]
    var url: String = ""
    var imageUrl: String = ""
   
    
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillDisappear(true)
        
        print(document)
        
        // 이미지 세팅
        
        // 페이지 로드
        
//        loadWebPateT##url: String##Strin)
    }
    
        override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               navigationController?.setNavigationBarHidden(false, animated: animated)
           }
    
    
    
    func loadWebPate(_ url: String){
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url:myUrl!)
        myWebView.load(myRequest)
        
        myWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
}
