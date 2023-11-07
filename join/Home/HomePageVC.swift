//
//  HomePageVC.swift
//  join
//
//  Created by ChrisLien on 2020/12/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Parchment

class NavigationBarPagingView: PagingView {
  
    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        pageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class NavigationBarPagingViewController: PagingViewController {
    override func loadView() {
        view = NavigationBarPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view)
    }
}

class ConstantIndicatorView: PagingIndicatorView {
    
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
      if let attributes = layoutAttributes as? PagingIndicatorLayoutAttributes {
        backgroundColor = attributes.backgroundColor
        layer.cornerRadius = layoutAttributes.bounds.height / 2
        layer.masksToBounds = true
        //this frame.with is the indicator with
        frame = CGRect(origin: frame.origin, size: CGSize(width: 10, height: frame.height))
        center = layoutAttributes.center
      }
    }
}

class HomePageVC: UIViewController {
    
    let pagingVC = NavigationBarPagingViewController()
    var vcList: [UIViewController] = [UIViewController]()
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let FriendHomePageVC = storyboard.instantiateViewController(withIdentifier: "FriendHomePageVC")
        let PostHomePageVC = storyboard.instantiateViewController(withIdentifier: "PostHomePageVC")
        let PartyHomePageVC = storyboard.instantiateViewController(withIdentifier: "PartyHomePageVC")
        NotificationCenter.default.addObserver(self, selector: #selector(goSuccessPartyVC), name: NSNotification.Name(rawValue: "goSuccessPartyVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callQueryUserService), name: Notifications.queryUser, object: nil)
        [FriendHomePageVC,PostHomePageVC,PartyHomePageVC].forEach { vcList.append($0) }
        
        setupSearchBtn(itemIndex: 0)
        configurePagingVC()
        
        addChild(pagingVC)
        view.addSubview(pagingVC.view)
        pagingVC.view.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        pagingVC.didMove(toParent: self)
        pagingVC.collectionView.isScrollEnabled = false
        navigationItem.titleView = pagingVC.collectionView
        
        preloadVCs()
        checkUserNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMainBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationItem.titleView?.frame = CGRect(origin: .zero, size: navigationBar.bounds.size)
        pagingVC.menuItemSize = .fixed(width: 85, height: navigationBar.bounds.height)
    }
    
    func configurePagingVC() {
        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.borderOptions = .hidden
        pagingVC.menuItemLabelSpacing = 0
        pagingVC.menuBackgroundColor = .clear
        pagingVC.indicatorClass = ConstantIndicatorView.self
        pagingVC.indicatorColor = Colors.themePurple
        pagingVC.textColor = Colors.rgb188Gray
        pagingVC.font = .systemFont(ofSize: 16)
        pagingVC.selectedTextColor = Colors.rgb41Black
        pagingVC.selectedFont = .boldSystemFont(ofSize: 20)
    }
    
    func checkUserNotification() {
       
        let jsonMemo = globalData.jasonMemo
        switch globalData.callapi {
        case "queryuser_mypage":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.queryuser, object: nil, userInfo: ["uid": jsonMemo.uid, "otherReason": jsonMemo.otherReason])
        case "getpost":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getpost, object: nil, userInfo: ["uid": jsonMemo.uid, "pid": jsonMemo.pid])
        case "getPostComtDetail":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getpost, object: nil, userInfo: ["cmtid": jsonMemo.cmtid, "pid": jsonMemo.pid, "scroll": "1"])
        case "getparty":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getparty, object: nil, userInfo: ["uid": jsonMemo.ptid, "ptid": jsonMemo.uid])
        case "getPartyComtDetail":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getparty, object: nil, userInfo: ["cmtid": jsonMemo.cmtid, "ptid": jsonMemo.ptid, "isPublic": jsonMemo.isPublic, "username": jsonMemo.username, "userIcon": jsonMemo.userIcon, "uid": jsonMemo.uid, "scroll": "1", "myUid": jsonMemo.myUid])
        case "getUnreviewedList":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getUnreviewedList, object: nil, userInfo: ["uid": jsonMemo.uid, "ptid": jsonMemo.ptid])
        case "getAttendanceList":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
            NotificationCenter.default.post(name: userNotifications.getAttendanceList, object: nil, userInfo: ["ptid": jsonMemo.ptid])
        case "openchat":
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectChat"), object: nil)
            NotificationCenter.default.post(name: userNotifications.openChat, object: nil, userInfo: ["chtid": jsonMemo.chtid, "senduid": jsonMemo.senduid, "username": jsonMemo.username, "userIcon": jsonMemo.userIcon, "shortid": jsonMemo.shortid])
        case "getphoto":
            print("here")
//        case "getpartylist":
//            pagingVC.select(index: 2,animated: true)
//        case "getpostlist":
//            pagingVC.select(index: 1,animated: true)
        default:
            break
        }
    }

    fileprivate func setupSearchBtn(itemIndex: Int) {
        var rightButton: UIBarButtonItem!
        switch itemIndex {
        case 0:
            rightButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goFilt))
        case 1:
            rightButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goSearchPost))
        default:
            rightButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goSearchParty))
        }
        rightButton.image = UIImage(named: "search-solid-20pt × 20pt")
        rightButton.tintColor = Colors.themePurple
        navigationItem.rightBarButtonItem = rightButton
    }
    
    fileprivate func preloadVCs () {
        for viewController in tabBarController?.viewControllers ?? [] {
            if let navigationVC = viewController as? UINavigationController, let rootVC = navigationVC.viewControllers.first {
                let _ = rootVC.view
            } else {
                let _ = viewController.view
            }
        }
    }

    @objc func callQueryUserService() {
        let request = createHttpRequest(Url: globalData.QueryUser_MyPageUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data,
                  error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let info = responseJSON["list"] as? [[String: Any]]
                        {
                            parseUserInfo(info: info[0])
                            globalData.location_rq_array = (info[0]["location_rq_name"] as! String).components(separatedBy: ",")
                            globalData.location_rq_combine_array = combineArray(idArr: (info[0]["location_rq"] as! String).components(separatedBy: ","), txtArr:globalData.location_rq_array)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func goSearchParty() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goFilt() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchConditionVC") as! SearchConditionVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goSearchPost() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.isParty = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goSuccessPartyVC() {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessVC") as! SuccessVC
        self.present(VC,animated: true)
    }
}

extension HomePageVC: PagingViewControllerDataSource {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 3
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return vcList[index]
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        let titleArray = ["想認識","隨手拍","揪一起"]
        return PagingIndexItem(index: index, title: titleArray[index])
    }
}

extension HomePageVC: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController,didScrollToItem pagingItem: PagingItem,startingViewController: UIViewController?,destinationViewController: UIViewController,transitionSuccessful: Bool) {
        let item = pagingItem as! PagingIndexItem
        setupSearchBtn(itemIndex: item.index)
    }
}

//    func count() {
//        let count = navigationController?.viewControllers.count
//        if count! > 1 {
//            navigationController?.popToViewController(self, animated: true)
//        }
//    }
