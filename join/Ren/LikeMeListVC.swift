//
//  LikeListVC.swift
//  join
//
//  Created by 連亮涵 on 2020/8/3.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout
import MJRefresh

class LikeMeListVC: UIViewController {
    
    lazy var cv_list: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: self.view.frame.width/2 - 15, height: self.view.frame.width/1.9)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = Colors.rgb248Gray
        cv.register(LikeMeCVCell.self, forCellWithReuseIdentifier: "likeMeList")
        return cv
    }()
    
    let img_heart: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "heart-solid-23pt × 20pt")
        return iv
    }()
    
    let lbl_like: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb149Gray
        lbl.font = .systemFont(ofSize: 15)
        lbl.text = "0位表示喜歡你"
        return lbl
    }()
    
    let v_hide = UIView()
    
    let lbl_blur_like: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.text = "升級至VIP就可以看到喜歡你的粉絲，\n且還可以超級喜歡心儀的對象"
        return lbl
    }()
    
    lazy var btn_vip: UIButton = {
        let btn = UIButton()
        btn.setTitle("立即升級VIP", for: .normal)
        btn.layer.cornerRadius = 20
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.isUserInteractionEnabled = true
        return btn
    }()

    let rc_head = MJRefreshNormalHeader()
    let rc_foot = MJRefreshAutoFooter()
    
    var likeCount = 0
    var pageCount = 0
    var isVip = ""
    var postEnd = false
    var likeArray:[QueryLikeMe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "誰喜歡我"
        hideMainBar()
        setupMJRefresh()
        setAnchors()
        callQueryLikeMEService(block: 0, refresh: false, toTop: false)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(hideBlurView), name: NSNotification.Name(rawValue: "hideBlurView"), object: nil)
        if isVip == "N" {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            let img_blur_heart = UIImageView(image: UIImage(named: "heart-solid-79pt × 72pt"))
            [blurView,img_blur_heart,lbl_blur_like,label,btn_vip].forEach { v_hide.addSubview($0) }
            blurView.anchor(top: v_hide.topAnchor, leading: v_hide.leadingAnchor, bottom: v_hide.bottomAnchor, trailing: v_hide.trailingAnchor)
            img_blur_heart.frame = CGRect(x: view.frame.width/2 - 25, y: view.frame.height/4, width: 58, height: 50)
            img_blur_heart.center.x = view.center.x
            img_blur_heart.tintColor = .red
            //
            lbl_blur_like.frame = CGRect(x:0 , y: img_blur_heart.frame.origin.y + 50 + 25, width: self.view.frame.width, height: 30)
            label.frame = CGRect(x: 0, y: lbl_blur_like.frame.origin.y + 30 + 50, width: self.view.frame.width, height: 50)
            btn_vip.frame = CGRect(x: view.frame.width/2 - 80, y: label.frame.origin.y + 50 + 80, width: 160, height: 40)
            btn_vip.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: 20)
            let goVip = UITapGestureRecognizer(target: self, action: #selector(goBuyVip))
            btn_vip.addGestureRecognizer(goVip)
        } else if isVip == "Y" {
            v_hide.isHidden = true
        }
    }
    
    func setupMJRefresh() {
        rc_head.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        cv_list.mj_header = rc_head
        rc_foot.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        cv_list.mj_footer = rc_foot
    }
    
    func setAnchors() {
        [img_heart,lbl_like,cv_list,v_hide].forEach { view.addSubview($0) }
        img_heart.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 15, bottom: 0, right: 0), size: CGSize(width: 23, height: 20))
        lbl_like.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: img_heart.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 5, bottom: 0, right: 0), size: CGSize(width: 150, height: 20))
        v_hide.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        cv_list.anchor(top: img_heart.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 13, left: 0, bottom: 0, right: 0))
    }

    func callQueryLikeMEService(block:Int, refresh:Bool, toTop: Bool)
    {
        let request = createHttpRequest(Url: globalData.QueryLikeMeUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(block)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                DispatchQueue.main.async {
                    self.cv_list.mj_header!.endRefreshing()
                    self.cv_list.mj_footer!.endRefreshing()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        if refresh{
                            self.likeArray.removeAll()
                        }
                        //設定喜歡人數
                        let cnt = responseJSON["count"] as? Int ?? 0
                        self.likeCount = cnt
                        self.lbl_like.text = "\(self.likeCount)位表示喜歡你"
                        self.lbl_blur_like.text = "\(self.likeCount)個人對我有好感"
                        //
                        for like in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpLike = QueryLikeMe()
                            parseQueryLikeMe(querylikeme: tmpLike, like: like)
                            self.likeArray.append(tmpLike)
                        }
                        self.pageCount += 1
                        self.cv_list.reloadData()
                        if toTop {
                            self.cv_list.scrollToItem(at: IndexPath(row: 0, section: 0),at: .top,animated: true)
                        }
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                    self.cv_list.mj_header!.endRefreshing()
                    self.cv_list.mj_footer!.endRefreshing()
                }
            }
        }
        task.resume()
    }
    
    @objc func refresh() {
        pageCount = 0
        postEnd = false
        callQueryLikeMEService(block: 0, refresh: true, toTop: true)
    }
    
    @objc func loadmore() {
        if !postEnd
        {callQueryLikeMEService(block: pageCount, refresh: false, toTop: false)}
    }
    
    @objc func goBuyVip(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
        vc.from = "查看誰對我有興趣"
        self.present(vc,animated: true)
    }
    
    @objc func hideBlurView() {
        v_hide.isHidden = true
    }
    
    @IBAction func back(_ sender: Any) {
        showMainBar()
        navigationController?.popViewController(animated: true)
    }
}
extension LikeMeListVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likeArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "likeMeList", for: indexPath) as! LikeMeCVCell
        let like = likeArray[indexPath.item]
        cell.init_like_profile(uid: like.uid, username: like.username, gender_name: like.gender_name, age: String(like.age), location_name: like.location_name, constellation: like.constellation, constellation_name: like.constellation_name, img_urllist: like.img_urllist, width: view.frame.width/2 - 15, height: view.frame.width/1.9)
        return cell
    }
}
