//
//  PartyHomePageVC.swift
//  join
//
//  Created by ChrisLien on 2020/12/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import MJRefresh

class PartyHomePageVC: UIViewController, UITabBarControllerDelegate{

    lazy var cv_party: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: (self.view.frame.width - 48)/2 , height: self.view.frame.width/1.45)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = Colors.rgb248Gray
        cv.register(PartyHomePageCVCell.self, forCellWithReuseIdentifier: "PartyHomePageCVCell")
        return cv
    }()
    
    let btn_post: UIButton = {
        let btn = UIButton()
        btn.setImage(BasicIcons.add_36pt, for: .normal)
        btn.layer.masksToBounds = true
        btn.tintColor = .white
        btn.backgroundColor = Colors.themePurple
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    let v_top: UIView = {
        let v = UIView()
        v.backgroundColor = Colors.rgb248Gray
        return v
    }()
    
    let btn_new: UIButton = {
        let btn = UIButton()
        btn.setTitle("最新", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(Colors.themePurple, for: .normal)
        return btn
    }()
    
    let btn_hot: UIButton = {
        let btn = UIButton()
        btn.setTitle("熱門", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(Colors.rgb91Gray, for: .normal)
        return btn
    }()
    
    let rc_head = MJRefreshNormalHeader()
    let rc_foot = MJRefreshAutoFooter()
    lazy var activityIndicater = MyActivityIndicatorView()
    
    var status = 0
    var partyArray: [PartyHPData] = []
    var pageCount = 0
    var receipt = ""
    var postEnd = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(closePresentedVC), name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
        [v_top,cv_party,btn_post,activityIndicater].forEach { view.addSubview($0) }
        [btn_new,btn_hot].forEach { v_top.addSubview($0) }
        setupAnchors()  
        setupMJRefresh()
        setupButtons() 
        callPostService(type: 0, block: 0, refresh: false, toTop: false)
    }
    
    func setupMJRefresh() {
        rc_head.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        self.cv_party.mj_header = rc_head
        rc_foot.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        self.cv_party.mj_footer = rc_foot
    }
    
    func callPostService(type: Int,block: Int,refresh: Bool, toTop:Bool) {
        let request = createHttpRequest(Url: globalData.GetPartyListUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(block)&type=\(type)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                DispatchQueue.main.async {
                    self.cv_party.mj_header!.endRefreshing()
                    self.cv_party.mj_footer!.endRefreshing()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        
                        if refresh {
                            self.partyArray.removeAll()
                        }
                        
                        for party in responseJSON["list"] as! [[String: Any]]
                        {
                            self.partyArray.append(parsePartyHPData(party: party))
                        }
                        
                        self.pageCount += 1
                        self.cv_party.reloadData()
                        
                        if toTop {
                            self.cv_party.scrollToItem(at: IndexPath(row: 0, section: 0),at: .top,animated: true)
                        }
                        
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        self.postEnd = true
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                    self.cv_party.mj_header!.endRefreshing()
                    self.cv_party.mj_footer!.endRefreshing()
                }
            }
        }
        task.resume()
    }
    
    func checkNewPost() {
        NetworkManager.shared.callCheckPartyService { (code, msg) in
            self.btn_post.isEnabled = true
            switch code {
            case 0:
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "JoPostVC") as! Jo_PostVC
                self.present(VC, animated: true, completion: nil)
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 129:
                Alert.buyVIPAlert(vc: self, title: "無限揪團", msg: "一般會員同時可主辦一場活動，升級鑽石VIP可盡情主揪不限次數。", from: "主辦活動")
            case 100129:
                self.checkSuscription()
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func setupAnchors() {
        activityIndicater.center = view.center
        v_top.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: view.frame.width, height: 44))
        btn_new.anchor(top: v_top.topAnchor, leading: v_top.leadingAnchor, bottom: v_top.bottomAnchor, trailing: nil, padding: .init(top: 13, left: 18, bottom: 14, right: 0),size: CGSize(width: 35, height: 0))
        btn_hot.anchor(top: v_top.topAnchor, leading: btn_new.trailingAnchor, bottom: v_top.bottomAnchor, trailing: nil, padding: .init(top: 13, left: 18, bottom: 14, right: 0), size: CGSize(width: 35, height: 0))
        cv_party.anchor(top: v_top.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        btn_post.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 2.5, right: 15), size: CGSize(width: 50, height: 50))
    }
    
    
    func setupButtons() {
        btn_post.addTarget(self, action: #selector(toPost), for: .touchUpInside)
        btn_new.addTarget(self, action: #selector(refreshNew), for: .touchUpInside)
        btn_hot.addTarget(self, action: #selector(refreshHot), for: .touchUpInside)
    }
    
    func checkSuscription() {
        activityIndicater.active()
        NetworkManager.shared.checkIfPurchased { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let receipt):
                self.receipt = receipt
                self.getDvipOrderNo()
            case .failure(let error):
                self.activityIndicater.inactive()
                print(error)
            }
        }
    }
    
    func getDvipOrderNo() {
        NetworkManager.shared.callGetDvipOrderNoService { (code, orderNo, msg) in
            switch code {
            case 0:
                NetworkManager.shared.calliosPayService(orderNo: orderNo!, receipt: self.receipt) { (code, msg) in
                    self.activityIndicater.inactive()
                    print(code)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
                self.activityIndicater.inactive()
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
                self.activityIndicater.inactive()
            }
        }
    }

    @objc func refresh() {
        pageCount = 0
        postEnd = false
        callPostService(type: 0, block: 0, refresh: true, toTop: false)
    }
    
    @objc func refreshNew() {
        pageCount = 0
        postEnd = false
        status = 0
        btn_hot.setTitleColor(Colors.rgb91Gray, for: .normal)
        btn_new.setTitleColor(Colors.themePurple, for: .normal)
        callPostService(type: 0, block: 0, refresh: true, toTop: true)
    }
    
    @objc func refreshHot() {
        pageCount = 0
        postEnd = false
        status = 1
        btn_hot.setTitleColor(Colors.themePurple, for: .normal)
        btn_new.setTitleColor(Colors.rgb91Gray, for: .normal)
        callPostService(type: 1, block: 0, refresh: true, toTop: true)
    }
    
    @objc func loadmore() {
        if !postEnd {
            callPostService(type: 0, block: pageCount, refresh: false, toTop: false)
        }
    }
    
    @objc func toPost() {
        btn_post.isEnabled = false
        checkNewPost()
    }
    
    @objc func closePresentedVC() {
        if presentedViewController != nil {
           presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

extension PartyHomePageVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partyArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "PartyHomePageCVCell", for: indexPath) as! PartyHomePageCVCell
        let party = partyArray[indexPath.item]
        cell.init_cell(partyHPData: party, width: (self.view.frame.width - 48)/2, height: self.view.frame.width/1.45)
        return cell
    }
}
