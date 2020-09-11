//
//  SearchOptionViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/11.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit


protocol EditSearchOptionDelegate {
    func didSearchOptionEditDone(_ controller: SearchOptionViewController, searchOption: SearchOption)
}

class SearchOptionViewController: UIViewController {
    
    var searchOption = SearchOption()
    var delegate: EditSearchOptionDelegate?
    
    @IBOutlet var switchSort: UISwitchCustom!
    @IBOutlet var scSize: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(searchOption)
        setUp()
    }
    
    func setUp(){
        print("setUp")
        
        // 정확도순
        switch searchOption.sort {
        case "accuracy":
            switchSort.isOn = false
            break
        case "recency":
            switchSort.isOn = true
            break
            
        default:
            print("no way")
            switchSort.isOn = false
        }
        
        // 표시 개수
        switch searchOption.size {
        case 80:
            scSize.selectedSegmentIndex = 2
            break
        case 40:
            scSize.selectedSegmentIndex = 1
            break
        // case 20:
        default:
            scSize.selectedSegmentIndex = 0
        }
        
        
    }
    
    func saveSearchOption(){
        print("saveSearchOption")
        
    }
    
    ///////////////////////////////////
    
    @IBAction func switchChange(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            searchOption.sort = "recency"
        } else {
            searchOption.sort = "accuracy"
        }
    }
    
    
    @IBAction func scChange(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case 1:
            searchOption.size = 40
            break
        case 2:
            searchOption.size = 80
            break;
        // case 0:
        default:
            searchOption.size = 20
        }
    }
    
    @IBAction func btnDeleteHistory(_ sender: UIButton) {
        print("delete history")
    }
    /////////////////////////////////////////////
    
    @IBAction func btnCancel(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        if delegate != nil {
            print("hello")
            delegate?.didSearchOptionEditDone(self, searchOption: searchOption)
        }
        saveSearchOption()
        
//         dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
    }
}
