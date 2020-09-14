//
//  DetailImageViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/11.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit
import WebKit


class DetailImageViewController: UIViewController, UIScrollViewDelegate {

    var document: NSDictionary = [:]
    var url: String = ""
    var imageUrl: String = ""
    var isHideImage: Bool = false
   
    
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillDisappear(true)
        myWebView.scrollView.delegate = self
        
        print(document)
        
        // 이미지 세팅
        setImage()
        
        // 페이지 로드
        setWeb()
        
//        loadWebPateT##url: String##Strin)
    }
    
        override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               navigationController?.setNavigationBarHidden(false, animated: animated)
           }
    
    
    func setImage() {
        imageView.downloaded(from: document.value(forKeyPath: "image_url") as! String)
    }
    
    func setWeb() {
        loadWebPate(document.value(forKeyPath: "doc_url") as! String)
    }
    
    // 웹뷰 스크롤하면 이미지 감추기

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if (!isHideImage && scrollView.contentOffset.y >= 120) {
//            print(imageView.constraints)
            isHideImage.toggle()
            hideImage(isHideImage)
        } else if (isHideImage && scrollView.contentOffset.y < 120) {
            isHideImage.toggle()
            hideImage(isHideImage)
        }
        
    }
    
    func hideImage(_ isHide: Bool) {
        self.imageView.layoutIfNeeded() // force any pending operations to finish

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let height: CGFloat = isHide ? 0 : 400
            self.imageView.constraints[2].constant = height
            self.view.layoutIfNeeded()
        })
    }
    

    
    
    func loadWebPate(_ url: String){
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url:myUrl!)
        myWebView.load(myRequest)
    }
}
