//
//  ViewController.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit
import DropDown

class ViewController: UIViewController, UISearchBarDelegate, EditSearchOptionDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchResultHelperView: UIStackView!
    @IBOutlet var btnPreviousPage: UIButton!
    @IBOutlet var btnNextPage: UIButton!
    @IBOutlet var lblCurrentPage: UILabel!
    @IBOutlet var svSearchBar: UIStackView!
    @IBOutlet var svSelectModeBar: UIStackView!
    
    // 선택 모드에서 몇개 선택했는지 알려주는
    @IBOutlet var lblSelectedCount: UILabel!
    
    
    var apiReulstDocument: NSArray = []
    var searchOption = SearchOption()
    var isEndPage: Bool = false
    var isHideSearchHelperView: Bool = false
    var isNoSearch: Bool = false
    var isRefresh: Bool = false
    
    // 애니메이션 용 변수
    var isNext: Bool = false
    
    // 검색기록용 변수
    let searchHistoryDropDown = DropDown()
    var searchHistory = [String]()
    
    
    // 컬렉션뷰 셀렉트 모드용 변수
    enum Mode {
        case view
        case select
    }
    var collectionViewMode: Mode = .view {
        didSet {
            switch collectionViewMode {
            case .view:
                collectionView.allowsMultipleSelection = false
                break
                
            case .select:
                collectionView.allowsMultipleSelection = true
                break
            }
        }
    }
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    
    
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
        // 선택 모드바 처음에 숨기기
        self.svSelectModeBar.constraints[0].constant = 0
        self.svSelectModeBar.isHidden = true
        
        
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
        
        
        // 네비게이션바 숨기기
        //        viewWillDisappea(true)
        viewWillAppear(false)
        
        // 검색옵션 불러오기
        loadSearchData()
        // 검색창 드랍다운 설정
        
        searchHistoryDropDown.anchorView = searchBar
        searchHistoryDropDown.dataSource = searchHistory
        searchHistoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        searchHistoryDropDown.width = searchBar.frame.width-30
        searchHistoryDropDown.bottomOffset = CGPoint(x: 30, y:(searchHistoryDropDown.anchorView?.plainView.bounds.height)!)
        
        // 컬렉션 뷰 롱 프레스 제스처 추가
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        longPressGR.delaysTouchesEnded = false
        self.collectionView.addGestureRecognizer(longPressGR)
        
        // 검색창에 있는 값을 수정해보려고했는데 실패..
        //        print(searchBar.searchTextField)
        
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            
            return
        }
        hideSelectModeBarView(false)
        
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            _ = self.collectionView.cellForItem(at: indexPath)
            print(indexPath.row)
            collectionViewMode = collectionViewMode == .view ? .select : .view
            
            
        } else {
            print("Could not find index path")
        }
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
//            print("왼쪽 스와이프 ; 다음페이지")
            if !isEndPage {
                isNext = true
                searchOption.page += 1
                search()
            } else {
                print("마지막 페이지")
            }
            
        } else if gesture.direction == .right {
//            print("오른쪽 스와이프 ; 이전페이지")
            if searchOption.page > 1 {
                isNext = false
                searchOption.page -= 1
                search()
            } else {
                print("첫번째 페이지")
            }
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
//        print("새로고침")
        isRefresh = true
        search()
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print(segue.identifier!)
        switch segue.identifier {
        case "searchOption":
            let searchOptionViewController = segue.destination as! SearchOptionViewController
            searchOptionViewController.searchOption = searchOption
            searchOptionViewController.delegate = self
            break
            
        case "detailImage":
            let detailImageViewController = segue.destination as! DetailImageViewController
            detailImageViewController.document = apiReulstDocument[sender as! Int] as! NSDictionary
            
            //            print(sender as! Int)
            break
        default:
            print("no way")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // 컬렉션뷰 상하 제스처
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.y)
        if !isHideSearchHelperView && scrollView.contentOffset.y >= 30 {
            isHideSearchHelperView.toggle()
            hideSearchHelperView(isHideSearchHelperView)
        } else if isHideSearchHelperView && scrollView.contentOffset.y < 30 {
            isHideSearchHelperView.toggle()
            hideSearchHelperView(isHideSearchHelperView)
        }
    }
    
    func hideSearchHelperView(_ isHide: Bool) {
        self.searchResultHelperView.layoutIfNeeded() // force any pending operations to finish
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let height: CGFloat = isHide ? 0 : 40
            self.searchResultHelperView.constraints[0].constant = height
            self.searchResultHelperView.layoutIfNeeded()
        })
    }
    
    func hideSelectModeBarView(_ isHide: Bool) {
        collectionViewMode = Mode.view
        self.view.layoutIfNeeded() // force any pending operations to finish
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.svSelectModeBar.isHidden = isHide
            let height: CGFloat = isHide ? 0 : 40
            self.svSelectModeBar.constraints[0].constant = height
            self.view.layoutIfNeeded()
        })
    }
    
    // 서치옵션뷰컨트롤러랑 데이터 공유 위한 함수
    func didSearchOptionEditDone(_ controller: SearchOptionViewController, searchOption: SearchOption) {
//        print(searchOption)
        self.searchOption = searchOption
    }
    
    func didSearchHistoryDelete(_ controller: SearchOptionViewController) {
        if let searchHistory = UserDefaults.standard.value(forKey: "History") {
            self.searchHistory = searchHistory as! [String]
//            print(searchHistory)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query: String = searchBar.searchTextField.text!
//        print(query)
        
        searchOption.query = query
        
        search()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 처음 앱을 실행시킨 상태가 아니라면 보이지 않음
        // 화면 전환을 하고 난뒤에 검색기록이 자동으로 노촐되지 않도록 최초에 서치바에 입력을 하려고 했을때만 작동
        if isNoSearch {
            return
        }
        
        searchHistoryDropDown.selectionAction = {
            (index: Int, item: String) in
//            print("Selected item: \(item) at index: \(index)")
            // 공유, 정보, 다운로드
            
            searchBar.text = item
        }
//        searchHistoryDropDown.width = searchBar.frame.width-30
//        searchHistoryDropDown.bottomOffset = CGPoint(x: 30, y:(searchHistoryDropDown.anchorView?.plainView.bounds.height)!)
        searchHistoryDropDown.show()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 현재 타이핑한 문자열을 포함하는 리스트로 갱신
        searchHistoryDropDown.dataSource = searchHistory.filter{ string in
            return string.localizedCaseInsensitiveContains(searchBar.text!) }
        
        
        //         searchHistoryDropDown.width = searchBar.frame.width-30
//        searchHistoryDropDown.bottomOffset = CGPoint(x: 30, y:(searchHistoryDropDown.anchorView?.plainView.bounds.height)!)
        searchHistoryDropDown.show()
    }
    
    func search() {
        // 검색 키워드 앞뒤 공백 트림
        searchOption.query = searchOption.query.trimmingCharacters(in: .whitespacesAndNewlines)
        //        searchBar.searchTextField.text = searchOption.query
        
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
            
            
            
            self.isEndPage = responseObject.value(forKeyPath: "meta.is_end")! as! Int == 0 ? false : true
            
            
            
            // 개수 가져오기
            
//            print(self.apiReulstDocument.count)
            //        print(type(of: apiReulstDocument[0]))
            
            //        for i in 0 ..< apiReulstDocument.count {
            //            print((apiReulstDocument[i] as! NSDictionary).value(forKey: "thumbnail_url") as! String)
            //        }
            
            DispatchQueue.main.async {
                
                // 현재 페이지 보여주는 라벨 갱신
                self.lblCurrentPage.text = String( self.searchOption.page) + " 페이지"
                
                
                // 카카오 이미지 검색 size를 1로 검색해도 50까지 밖에 검색이 안된다..
                if self.isEndPage || self.searchOption.page >= 50 {
                    // 다음 페이지 버튼 비활성화
                    self.btnNextPage.isEnabled = false
                } else {
                    self.btnNextPage.isEnabled = true
                }
                
                if self.searchOption.page <= 1 {
                    // 이전 페이지 버튼 비활성화
                    self.btnPreviousPage.isEnabled = false
                } else {
                    self.btnPreviousPage.isEnabled =  true
                }
                
                
                // 페이지 로드 애니메이션
                var side: CATransitionSubtype = CATransitionSubtype.fromRight
                if self.isRefresh {
                    self.isRefresh.toggle()
                    side = CATransitionSubtype.fromBottom
                    
                } else if self.isNext {
                    side = CATransitionSubtype.fromRight
                } else {
                    side = CATransitionSubtype.fromLeft
                }
                
                self.collectionView.layer.add(self.swipeTransitionToLeftSide(side), forKey: nil)
                
                
                self.collectionView.reloadData()
                
                // search result helper view extend
                self.view.layoutIfNeeded() // force any pending operations to finish
                
//                print(self.searchResultHelperView.constraints[0])
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    
                    self.searchResultHelperView.constraints[0].constant = 40
                    
                    self.view.layoutIfNeeded()
                })
                
                if !self.isNoSearch {
                    self.isNoSearch.toggle()
                    self.collectionView.refreshControl = UIRefreshControl()
                    self.collectionView.refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
                }
            }
            
            // 검색기록
            self.recordSearchKeyword()
        }
    }
    
    func swipeTransitionToLeftSide(_ side: CATransitionSubtype) -> CATransition {
        let transition = CATransition()
        transition.startProgress = 0.0
        transition.endProgress = 1.0
        transition.type = CATransitionType.push
        transition.subtype = side
        transition.duration = 0.3
        
        return transition
    }
    
    @IBAction func btnPreviousPage(_ sender: UIButton) {
        isNext = false
        searchOption.page -= 1
        search()
    }
    
    @IBAction func btnNextPage(_ sender: UIButton) {
        isNext = true
        searchOption.page += 1
        search()
    }
    
    @IBAction func btnShareImageLink(_ sender: UIButton) {
        if dictionarySelectedIndexPath.count == 0 {
            showToast(message: "1개 이상 선택해주세요", font: .systemFont(ofSize: 12.0))
            return
        }
        
//        print("공유하기")
        
        let shareData = dictionarySelectedIndexPath.map{
            item in
            return (apiReulstDocument[item.key[1]] as! NSDictionary).value(forKey: "image_url") as! String
        }
//        print(shareData)
        
        let activityController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func btnExitSelectMode(_ sender: UIButton) {
//        print("나가기")
        hideSelectModeBarView(true)
        collectionView.reloadData()
    }
    
    @IBAction func btnSaveImages(_ sender: UIButton) {
        if dictionarySelectedIndexPath.count == 0 {
            showToast(message: "1개 이상 선택해주세요", font: .systemFont(ofSize: 12.0))
            return
        }
        
        dictionarySelectedIndexPath.forEach{
            item in
            
            
            if let url = URL(string: (apiReulstDocument[item.key[1]] as! NSDictionary).value(forKeyPath: "image_url") as! String),
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
//                print("image download")
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        showToast(message: String(dictionarySelectedIndexPath.count)+"개 이미지 저장 완료!", font: .systemFont(ofSize: 12.0))
    }
    
}

extension ViewController: UICollectionViewDelegate {
    // 셀렉션뷰 클릭했을때 처리하는 부분
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionViewMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            performSegue(withIdentifier: "detailImage", sender: indexPath[1])
            break
        case .select:
            //            print("셀렉트 모드!")
            dictionarySelectedIndexPath[indexPath] = true
            let selectedItems = dictionarySelectedIndexPath.filter {
                item in
                return item.value
            }
            lblSelectedCount.text = String(selectedItems.count) + "개 선택됨"
            break
        }
//        print(indexPath)
    }
    
    // 셀렉션뷰 선택 해제시 처리하는 부분
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionViewMode != .select {
            return
        }
        
        dictionarySelectedIndexPath[indexPath] = false
        let selectedItems = dictionarySelectedIndexPath.filter {
            item in
            return item.value
        }
        lblSelectedCount.text = String(selectedItems.count) + "개 선택됨"
        dictionarySelectedIndexPath = selectedItems
    }

}


extension ViewController: UICollectionViewDataSource {
    
    // 컬렉션뷰 갱신마다 컬렉션뷰 셀의 개수 지정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("numberOfItemsInSection")
        
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
    
    // 컬렉션뷰 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
}



// 검색옵션, 검색기록 관련 함수
extension ViewController {
    func loadSearchData(){
//        print("loadSearchOption")
        let userDefaults = UserDefaults.standard
        
        if let sort = userDefaults.value(forKey: Setting.Option.sort.rawValue),
            let size = userDefaults.value(forKey: Setting.Option.size.rawValue) {
            self.searchOption.sort = sort as! String
            self.searchOption.size = size as! Int
//            print(self.searchOption)
        }
        
        if let searchHistory = userDefaults.value(forKey: "History") {
            self.searchHistory = searchHistory as! [String]
//            print(searchHistory)
        }
        
    }
    
    func recordSearchKeyword() {
        if searchHistory.contains(searchOption.query){
            return
        }
        
//        print("새로운 키워드 추가")
        searchHistory.append(searchOption.query)
        UserDefaults.standard.set(searchHistory, forKey: "History")
    }
    
}


// 검색 옵션
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

// 유저 검색 옵션 저장용
struct Setting{
    enum Option:String{
        case sort
        case size
    }
}
