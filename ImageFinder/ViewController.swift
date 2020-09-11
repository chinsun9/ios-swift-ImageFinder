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
        size = 20
        sort = "accuracy"
        page = 1
        query = ""
    }
}

class ViewController: UIViewController, UISearchBarDelegate, EditSearchOptionDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchResultHelperView: UIStackView!
    
    var apiReulstDocument: NSArray = []
    var searchOption = SearchOption()
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.collectionViewLayout = layout
        
        
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 검색 결과 화면에 보이는 뷰 처음에 숨기기
        self.searchResultHelperView.constraints[0].constant = 0
        
        
        
        // 스와이프 제스처
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
//        swipeDown.direction = .down
//        self.view.addGestureRecognizer(swipeDown)
//
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
//        swipeUp.direction = .up
//        self.view.addGestureRecognizer(swipeUp)
        
        
        // 리프레쉬 컨트롤
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            print("왼쪽 스와이프")
        } else if gesture.direction == .right {
            print("오른쪽 스와이프")
        }
        
            // 근데 콜렉션뷰에서 스크롤하면 상하 제스처가 먹히지 않음....
//        else if gesture.direction == .down {
//            print("아래쪽 스와이프 ; 새로고침")
//            // 최상단일 경우에만 새로고침
//            if collectionView.contentOffset.y <= 10 {
//                print("새로고침")
//            }
//        } else if gesture.direction == .up {
//            print("위쪽 스와이프")
//        }
    }
    
    @objc func handleRefreshControl() {
       // Update your content…
        print("새로고침")
        search()

       // Dismiss the refresh control.
       DispatchQueue.main.async {
          self.collectionView.refreshControl?.endRefreshing()
        
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        switch segue.identifier {
        case "searchOption":
            print("segue:searchOption")
            let searchOptionViewController = segue.destination as! SearchOptionViewController
            searchOptionViewController.searchOption = searchOption
            searchOptionViewController.delegate = self
        default:
            print("no way")
        }
    }
    
    // 컬렉션뷰 상하 제스처
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y >= 30 {
            self.searchResultHelperView.constraints[0].constant = 0
        } else {
            self.searchResultHelperView.constraints[0].constant = 40
        }
        
        // 새로고침 기능 -> 리프레쉬 컨트롤 이용...
//        if scrollView.contentOffset.y <= -150 {
//            print("새로고침")
//            scrollView.contentInsetAdjustmentBehavior = .never
//            scrollView.contentOffset.y = 0
//
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 1.0, animations: {
//                scrollView.contentOffset.y = 0
//                }, completion: nil)
//            }
//
//            search()
//            //scrollView.contentInsetAdjustmentBehavior = .always
//        }
    }
    
        
    
    // 서치옵션뷰컨트롤러랑 데이터 공유 위한 함수
    func didSearchOptionEditDone(_ controller: SearchOptionViewController, searchOption: SearchOption) {
        print(searchOption)
        self.searchOption = searchOption
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query: String = searchBar.searchTextField.text!
        print(query)
        
        searchOption.query = query
        
        search()
    }
    
    func search() {
//
        
        let apiRequest = APIResquest()
                
                apiRequest.sendRequest(searchOption) { responseObject, error in
                    guard let responseObject = responseObject, error == nil else {
                        print(error ?? "error")
                        return
                    }
                    
        //            print(responseObject)
        //            print(type(of: responseObject))
                    
        //            print(responseObject["meta"]!["pageable_count"]!)
                    // print(responseObject.value( forKeyPath: "meta.pageable_count" )!)
                    self.apiReulstDocument = responseObject.value(forKeyPath: "documents")! as! NSArray
                    
                    // 개수 가져오기
                    
                    print(self.apiReulstDocument.count)
                    //        print(type(of: apiReulstDocument[0]))
                            
                    //        for i in 0 ..< apiReulstDocument.count {
                    //            print((apiReulstDocument[i] as! NSDictionary).value(forKey: "thumbnail_url") as! String)
                    //        }
                            
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        
                        // search result helper view extend
                        self.searchResultHelperView.layoutIfNeeded() // force any pending operations to finish

                        print(self.searchResultHelperView.constraints[0])
                        UIView.animate(withDuration: 0.4, animations: { () -> Void in
                           
                            self.searchResultHelperView.constraints[0].constant = 40
                            
                           self.searchResultHelperView.layoutIfNeeded()
                        })
                        

                        
                    }
                }
       
        
    }

    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
    }
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(apiReulstDocument.count != 0){
            return searchOption.size
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        
        cell.configure(with: (apiReulstDocument[indexPath[1]] as! NSDictionary).value(forKey: "thumbnail_url") as! String)
        
        
        return cell;

    }
    
}


extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
}
