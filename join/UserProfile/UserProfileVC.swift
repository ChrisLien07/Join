//
//  UserProfileVC.swift
//  join
//
//  Created by 連亮涵 on 2020/7/29.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import UIKit
import UICollectionViewLeftAlignedLayout
import MJRefresh
import FirebaseAuth
import FirebaseDatabase
import Cosmos

class UserProfileVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var tbv_profile: UITableView!
    @IBOutlet weak var btn_follow: UIButton!
    @IBOutlet weak var btn_DMChat: UIButton!
    @IBOutlet weak var v_mid: UIView!
    @IBOutlet weak var lbl_mid_info: UILabel!
    @IBOutlet weak var btn_superLike: SocialButton!
    @IBOutlet weak var btn_like: SocialButton!
    @IBOutlet weak var btn_disLike: SocialButton!
    @IBOutlet weak var btn_chat: SocialButton!
    
    let activityIndicater = MyActivityIndicatorView()
    
    
    let sv_photos: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    let v_stars: CosmosView = {
        let v = CosmosView()
        v.settings.updateOnTouch = false
        v.settings.filledImage = ratingStar.fill_18pt
        v.settings.emptyImage = ratingStar.empty_18pt
        v.settings.fillMode = .precise
        v.settings.starSize = 20
        return v
    }()
   
    let lbl_review: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb91Gray
        lbl.textAlignment = .right
        return lbl
    }()
    
    let v_profile = ProfileDetailView()
    let v_numbers = NumSectionView()
    let v_line = UIView()
    let v_rating = UIView()
    let pg_control = UIPageControl()
    
    var ref: DatabaseReference!
    let rc_head = MJRefreshNormalHeader()
    var profile = UserInfo()
    
    var uid = ""
    var receipt = ""
    var titleArray: [String] = ["","職業","血型","個性"]
    var photoArry : [String] = []

    var isPresent = false
    var isRen = false
    var isMatch = false
    var status = "follow"
    
    lazy var imgHeight = self.view.frame.height*0.575
    lazy var v_numberHeight = self.view.frame.width*0.15

    override func viewDidLoad() {
        super.viewDidLoad()
        tbv_profile.delegate = self
        tbv_profile.dataSource = self
        sv_photos.delegate = self
        ref = Database.database().reference()
        
        if profile.username == "" , let navi = self.navigationController as? UserProfileNavi {
            isRen = navi.isRen
            isMatch = navi.isMatch
            uid = navi.uid
            isPresent = navi.isPresent
        }
        
        if isRen {
            self.title = "更多資訊"
            v_mid.frame.size.height = 35
            lbl_mid_info.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35)
            btn_follow.isHidden = true
            if isMatch {
                btn_chat.isHidden = false
            } else if !isMatch {
                btn_superLike.isHidden = false
                btn_like.isHidden = false
                btn_disLike.isHidden = false
            }
        } else {
            title = profile.username
            btn_follow.layer.cornerRadius = btn_follow.frame.height/2
            btn_follow.layer.borderColor = Colors.themePurple.cgColor
            btn_follow.layer.borderWidth = 1
            btn_DMChat.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_follow.frame.height/2)
        }
        
        view.addSubview(activityIndicater)
        activityIndicater.center = view.center
                
        v_profile.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v_line.backgroundColor = Colors.rgb217Gray
        btn_chat.backgroundColor = Colors.themePurple
        
        pg_control.frame = CGRect(x: 10, y: 15, width: 500, height: 30)
        pg_control.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        
        let tapRating = UITapGestureRecognizer.init(target: self, action: #selector(goRatingPage))
        v_rating.addGestureRecognizer(tapRating)
        
        [sv_photos,pg_control,v_profile,v_numbers,v_line,v_rating].forEach{ sv_main.addSubview($0) }
        [v_stars,lbl_review].forEach{ v_rating.addSubview($0) }
        setupMainConstraint()
        setupRatingsConstraint()
        callProfileService()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sv_main.contentSize.height = tbv_profile.frame.origin.y + tbv_profile.frame.size.height
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pg_control.currentPage = page
        let offset = CGPoint(x: CGFloat(page)*scrollView.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func callProfileService(){
        let request = createHttpRequest(Url: globalData.QueryUser_MyPageUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\(self.uid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        self.photoArry.removeAll()
                        let file = responseJSON["list"] as! [[String: Any]]
                        parseProfile(profile: self.profile, file: file[0])
                        
                        let array =  [self.profile.img_url1,
                                        self.profile.img_url2,
                                        self.profile.img_url3,
                                        self.profile.img_url4,
                                        self.profile.img_url5,
                                        self.profile.img_url6
                                    ]
                        array.forEach { if $0 != "" { self.photoArry.append($0) } }
                            
                        var imgCount = 0
                        for img in self.photoArry
                        {
                            let imgView = UIImageView()
                            imgView.frame = CGRect(x:self.view.frame.width * CGFloat(imgCount),y:0,width: self.view.frame.width,height: self.imgHeight)
                            imgView.contentMode = .scaleAspectFill
                            imgView.layer.masksToBounds = true
                            imgView.isUserInteractionEnabled = true
                            DownloadImage(view: imgView, img: img, id: "", placeholder: nil)
                            imgCount += 1
                            self.sv_photos.addSubview(imgView)
                        }
                        //
                        self.sv_photos.contentSize = CGSize(width: CGFloat(Int(self.view.frame.width)*self.photoArry.count), height: self.sv_photos.frame.size.height)
                        self.pg_control.numberOfPages = self.photoArry.count
                        self.pg_control.sizeToFit()
                        //
                        if self.profile.isMyself == 1 {
                            self.btn_follow.isHidden = true
                            self.btn_DMChat.isHidden = true
                        }
                        //
                        if self.profile.isfollowed == "1" {
                            self.status = "unfollow"
                            self.btn_follow.setTitle("取消追蹤", for: .normal)
                        } else if self.profile.isfollowed == "0" {
                            self.status = "follow"
                            self.btn_follow.setTitle("追蹤", for: .normal)
                        }
                        self.setList()
                        self.tbv_profile.reloadData()
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func reportUser(accuse_reason: String) {
        NetworkManager.shared.callReportService(target: "user", id: self.uid, accuse_reason: accuse_reason) { (code, msg) in
            switch code {
            case 0:
                Alert.basicActionAlert(vc: self, title: "抱歉，造成您的不悅", message: "我們已經收到您的檢舉通知，客服人員會盡快處理。", okBtnTitle: "確定", twoBtn: false) { (_) in
                    if !self.isRen {
                        self.back(0)
                    } else {
                        self.navigationController!.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disLike"), object: nil, userInfo: nil)
                        })
                    }
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code, msg: msg! ,vc: self)
            }
        }
    }
    
    func blockUser() {
        NetworkManager.shared.callBlockUserService(uid: self.uid) { (code, msg) in
            switch code {
            case 0:
                if !self.isRen {
                    self.back(0)
                } else {
                    self.navigationController!.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disLike"), object: nil, userInfo: nil)
                    })
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func callFollowService()//追蹤 取消追蹤
    {
        var url = ""
        if self.status == "follow"{
           url = globalData.FollowUserUrl
        } else if self.status == "unfollow" {
            url = globalData.UnfollowUserUrl
        }
        let request = createHttpRequest(Url: url, HttpType: "POST", Data: "token=\(globalData.token)&followuid=\(self.uid)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                self.btn_follow.isEnabled = true
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        let followerCount = responseJSON["followerCount"] as! String
                        self.v_numbers.lbl_follower_cnt.makeLable(string1: followerCount, string2: "\n粉絲人數")
                        self.btn_follow.isEnabled = true
                        if self.status == "follow" {
                            self.status = "unfollow"
                            self.btn_follow.setTitle("取消追蹤", for: .normal)
                        }
                        else if self.status == "unfollow" {
                            self.status = "follow"
                            self.btn_follow.setTitle("追蹤", for: .normal)
                        }
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func check(chtid: String)
    {
        let userID = Auth.auth().currentUser?.uid
        var CID_array: [String] = [String]()
        ref.child("chatroom_user").child(userID!).child("CID").observeSingleEvent(of: .value, with: { (snapshot) in
            if let CIDS = snapshot.value as? [String]
            {
                for CID in CIDS {
                    CID_array.append(CID)
                }
                
                if !CID_array.contains(chtid) {
                    CID_array.append(chtid)
                    self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
                }
            } else {
                CID_array.append(chtid)
                self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
            }
            self.btn_chat.isEnabled = true
            self.btn_DMChat.isEnabled = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomVC") as! ChatroomVC
            vc.chtid = chtid
            vc.username = self.profile.username
            vc.img_url = self.profile.img_url1
            vc.friend_uid = self.uid
            vc.friend_shortid = self.profile.shortid
            vc.from = "UserProfileVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }) { (error) in
            self.btn_chat.isEnabled = true
            self.btn_DMChat.isEnabled = true
            print("0")
        }
    }
    
    func callOpenDMChatService() {
        NetworkManager.shared.callOpenDMChatService(frienduid: self.uid) { (code, chtid, msg) in
            switch code {
            case 0:
                self.check(chtid: chtid!)
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
                self.btn_DMChat.isEnabled = true
                self.btn_chat.isEnabled = true
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            case 148:
                Alert.buyVIPAlert(vc: self, title: "立即私訊", msg: "升級VIP，可立即私訊對方，引起對方注意", from: "私訊")
                self.btn_DMChat.isEnabled = true
                self.btn_chat.isEnabled = true
            case 100148:
                self.checkSuscription()
                self.btn_DMChat.isEnabled = true
                self.btn_chat.isEnabled = true
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
                self.btn_DMChat.isEnabled = true
                self.btn_chat.isEnabled = true
            }
        }
    }
    
    func setupMainConstraint() {
        sv_main.anchor(top: sv_main.superview?.topAnchor, leading: sv_main.superview?.leadingAnchor, bottom: sv_main.superview?.bottomAnchor, trailing: sv_main.superview?.trailingAnchor)
        sv_photos.anchor(top: sv_main.topAnchor, leading: sv_main.leadingAnchor, bottom: nil, trailing: nil,size: CGSize(width: self.view.frame.width, height: imgHeight))
        v_profile.anchor(top: nil, leading: sv_photos.leadingAnchor, bottom: sv_photos.bottomAnchor, trailing: sv_photos.trailingAnchor,size: CGSize(width: 0, height: 94))
        v_numbers.anchor(top: sv_photos.bottomAnchor, leading: sv_photos.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: self.view.frame.width, height: v_numberHeight))
        v_line.anchor(top: v_numbers.bottomAnchor, leading: sv_photos.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: self.view.frame.width, height: 1))
        if isRen {
            v_rating.isHidden = true
            tbv_profile.anchor(top: v_line.bottomAnchor, leading: sv_photos.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: self.view.frame.width, height: 350))
        } else {
            v_rating.anchor(top: v_line.bottomAnchor, leading: sv_photos.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: self.view.frame.width, height: 50))
            tbv_profile.anchor(top: v_rating.bottomAnchor, leading: sv_photos.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: self.view.frame.width, height: 350))
        }
    }
    
    func setupRatingsConstraint() {
        v_stars.anchor(top: v_rating.topAnchor, leading: v_rating.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 15, left: 15, bottom: 15, right: 0) ,size: CGSize(width: 90, height: 20))
        lbl_review.anchor(top: v_rating.topAnchor, leading: nil, bottom: nil, trailing: v_rating.trailingAnchor,padding: .init(top: 14, left: 0, bottom: 14, right: 15),size: CGSize(width: 70, height: 22))
    }
    
    func setList(){
        self.title = profile.username
        v_profile.initView(username: profile.username, gender: profile.gender, age: String(profile.age), constellation_name: profile.constellation_name, constellation_id: profile.constellation_id, interest_name: profile.interest_name, location_name: profile.location_name)
        v_numbers.initView(party_cnt: profile.party_cnt, like_cnt: profile.like_cnt, follower_cnt: profile.follower_cnt, follow_cnt: profile.follow_cnt)
        v_stars.rating = Double(profile.avgStarRating)!
        lbl_review.text = "評論" + profile.reviewCount
    }
    
    @objc func pageChanged() {
        let offset = CGPoint(x: (sv_photos.frame.width) * CGFloat(pg_control.currentPage), y: 0)
        sv_photos.setContentOffset(offset, animated: true)
    }
    
    @objc func goRatingPage() {
        if profile.reviewCount != "0" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "RatingsVC") as! RatingsVC
            vc.uid = self.uid
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func goDMChat(_ sender: Any) {
        btn_DMChat.isEnabled = false
        callOpenDMChatService()
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
    
    @IBAction func follow(_ sender: Any) {
        btn_follow.isEnabled = false
        callFollowService()
    }
    
    @IBAction func chat(_ sender: Any) {
        btn_chat.isEnabled = false
        callOpenDMChatService()
    }
    
    @IBAction func like(_ sender: Any) {
        self.navigationController!.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notifications.like, object: nil, userInfo: nil)
        })
    }
    
    @IBAction func disLike(_ sender: Any) {
        self.navigationController!.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notifications.dislike, object: nil, userInfo: nil)
        })
    }
    
    @IBAction func superLike(_ sender: Any) {
        self.navigationController!.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notifications.superlike, object: nil, userInfo: nil)
        })
    }
    
    @IBAction func back(_ sender: Any) {
        if isRen {
            dismiss(animated: true, completion: .none)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
  
    @IBAction func goOption(_ sender: Any)
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
        let reportHandler = { (action:UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "檢舉用戶", message: nil, preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "訊息騷擾", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "001")
            }))
            alertMessage.addAction(UIAlertAction(title: "照片不雅", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "001")
            }))
            alertMessage.addAction(UIAlertAction(title: "詐騙行為", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "003")
            }))
            alertMessage.addAction(UIAlertAction(title: "其他", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "004")
            }))
            alertMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alertMessage,animated: true, completion: nil)
        }
        
        let blockHandler = { (action:UIAlertAction!) -> Void in
            let alertController = UIAlertController(title: "是否確定封鎖該用戶？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive){(UIAlertAction) in
                self.blockUser()
            }
             alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title:"取消",style: .cancel)
            alertController.addAction(cancelAction)
            self.present(alertController,animated: true, completion: nil)
        }

        let reportAction = UIAlertAction(title: "檢舉用戶", style: .destructive, handler: reportHandler)
        let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive, handler: blockHandler)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        [cancelAction,reportAction,blockAction].forEach{ optionMenu.addAction($0) }
        present(optionMenu,animated: true, completion: nil)
    }
}
    
extension UserProfileVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 115
        } else if indexPath.row == 3 {
            return 68
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell2", for: indexPath) as! MyProfileCell
        if titleArray.count > indexPath.row {
            cell.init_profile(title:titleArray[indexPath.row],user_info: self.profile.user_info, job_name:self.profile.job_name, bloodtype:self.profile.bloodtype, personality_name: self.profile.personality_name, width: tbv_profile.frame.width)
        }
        return cell
    }
}
