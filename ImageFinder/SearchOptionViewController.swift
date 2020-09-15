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
    func didSearchHistoryDelete(_ controller: SearchOptionViewController)
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
        UserDefaults.standard.set(searchOption.sort, forKey: Setting.Option.sort.rawValue)
        UserDefaults.standard.set(searchOption.size, forKey: Setting.Option.size.rawValue)
        
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
        
        let alert = UIAlertController(title: "검색 기록 삭제", message: "확인을 누르면 검색 기록이 삭제됩니다.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler : {
            ACTION in
            UserDefaults.standard.set([], forKey: "History")
            self.showToast(message: "삭제되었습니다.", font: .systemFont(ofSize: 12.0))
        } )
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler : nil)
        
        
        alert.addAction(cancel)
        alert.addAction(okAction)
        
        
        
        present(alert, animated: true, completion: nil)
   
        
    }
    /////////////////////////////////////////////
    
    @IBAction func btnCancel(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        if delegate != nil {
            delegate?.didSearchHistoryDelete(self)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        if delegate != nil {
//            print("hello")
            delegate?.didSearchOptionEditDone(self, searchOption: searchOption)
            delegate?.didSearchHistoryDelete(self)
        }
        saveSearchOption()
        
//         dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
    }
}
