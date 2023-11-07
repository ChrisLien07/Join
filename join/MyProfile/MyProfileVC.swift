//
//  MyProfileVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import MJRefresh
    
class MyProfileVC: UIViewController {
    
    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var v_top: UIView!
    @IBOutlet weak var v_mid: UIView!
    @IBOutlet weak var v_myParty: UIView!
    @IBOutlet weak var v_myPost: UIView!
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var tbv_userFile: UITableView!
    
    let img_user = UIImageView()
    let lbl_gender = UILabel()
    let lbl_vip = UILabel()
    let lbl_age = UILabel()
    let lbl_shortid = UILabel()
    let lbl_username = UILabel()
    let lbl_party_cnt = ProfileLabel(textAlignment: .center, line: 2)
    let lbl_like_cnt = ProfileLabel(textAlignment: .center, line: 2)
    
    let lbl_follower_cnt: UILabel = {
        let lbl = UILabel()
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let lbl_follow_cnt: UILabel = {
        let lbl = UILabel()
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let rc_head = MJRefreshNormalHeader()
    
    var profile = UserInfo()
    var titleArray: [String] = ["關於我","職業","血型","個性"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload_photo), name: NSNotification.Name(rawValue: "reload_photo"), object: nil)
        tbv_userFile.delegate = self
        tbv_userFile.dataSource = self
        //
        let tap1 = UITapGestureRecognizer.init(target: self, action: #selector(goMyParty))
        v_myParty.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(goMyPost))
        v_myPost.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer.init(target: self, action: #selector(updateUser))
        btn_edit.addGestureRecognizer(tap3)
        //
        sv_main.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        v_top.layer.cornerRadius = 10
        v_top.setupShadow(offsetWidth: 5, offsetHeight: 5, opacity: 0.05, radius: 3)
        v_mid.layer.cornerRadius = 5
        v_mid.setupShadow(offsetWidth: 5, offsetHeight: 5, opacity: 0.05, radius: 3)
        //
        img_user.frame = CGRect(x: 15, y: 11, width: 70, height: 70)
        img_user.layer.cornerRadius = img_user.frame.height/2
        img_user.layer.masksToBounds = true
        img_user.contentMode = .scaleAspectFill
        DownloadImage(view: img_user, img: globalData.user_img, id: "", placeholder:  UIImage(named: "user.png"))
        v_top.addSubview(img_user)
        //
        lbl_vip.frame = CGRect(x: 14 + img_user.frame.width + 14, y: 16, width: 58, height: 18)
        lbl_vip.layer.cornerRadius = lbl_vip.frame.height/2
        lbl_vip.text = "VIP"
        //
        if globalData.gender == "1" {
            lbl_gender.text = "♂"
        } else if globalData.gender == "2" {
            lbl_gender.text = "♀"
        }
        [lbl_vip,lbl_username,lbl_gender,lbl_age,lbl_shortid].forEach{ v_top.addSubview($0) }
        //設定追蹤者
        let followerTap = UITapGestureRecognizer.init(target: self, action: #selector(goFollowerPage))
        lbl_follower_cnt.addGestureRecognizer(followerTap)
        //設定追蹤人數
        let followingTap = UITapGestureRecognizer.init(target: self, action: #selector(goFollowingPage))
        lbl_follow_cnt.addGestureRecognizer(followingTap)
        [lbl_party_cnt,lbl_like_cnt,lbl_follower_cnt,lbl_follow_cnt].forEach{ v_mid.addSubview($0) }
        tbv_userFile.frame.size.height = 290
        setupTopStyle()
        setupMJRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callProfileService(refresh: false)
        showMainBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sv_main.contentSize.height = tbv_userFile.frame.origin.y + tbv_userFile.frame.size.height
    }
    
    func setupMJRefresh() {
        rc_head.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        sv_main.mj_header = rc_head
    }
    
    func callProfileService(refresh: Bool) {
        let request = createHttpRequest(Url: globalData.QueryUser_MyPageUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\("")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                if refresh {
                    DispatchQueue.main.async {
                        self.sv_main.mj_header!.endRefreshing()
                    }
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        let file = responseJSON["list"] as! [[String: Any]]
                        parseProfile(profile: self.profile, file: file[0])
                        self.profile.interest_name_array = self.profile.interest_name.components(separatedBy: ",")
                        self.setupList()
                        self.tbv_userFile.reloadData()
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                    self.sv_main.mj_header!.endRefreshing()
                }
            }
        }
        task.resume()
    }
    
    func setupFrame() {
        if profile.isvip == "Y" {
            lbl_username.frame = CGRect(x: 14 + img_user.frame.width + 14, y: 16 + lbl_vip.frame.height + 5, width: 60, height: 21)
        } else {
            lbl_username.frame = CGRect(x: 14 + img_user.frame.width + 14, y: 28, width: 60, height: 21)
        }
        lbl_username.sizeToFit()
        lbl_gender.frame = CGRect(x: after(lbl_username) + 8, y: lbl_username.frame.origin.y - 1.5, width: 24, height: 21)
        lbl_age.frame = CGRect(x: after(lbl_gender), y: lbl_username.frame.origin.y - 1.5, width: 24, height: 21)
        lbl_shortid.frame = CGRect(x: 14 + img_user.frame.width + 14, y: below(lbl_username), width: 150, height: 20)
        lbl_party_cnt.frame = CGRect(x: (v_mid.frame.width - 320)/2 , y: 0, width: 80, height: 56)
        lbl_like_cnt.frame = CGRect(x: after(lbl_party_cnt), y: 0, width: 70, height: 56)
        lbl_follower_cnt.frame = CGRect(x: after(lbl_like_cnt), y: 0, width:90, height: 56)
        lbl_follow_cnt.frame = CGRect(x: after(lbl_follower_cnt), y: 0, width: 80, height: 56)
    }
    
    func setupList() {
        if profile.isvip == "Y" { lbl_vip.isHidden = false } else { lbl_vip.isHidden = true }
        lbl_vip.backgroundColor = Colors.partyYellow
        lbl_username.text = profile.username
        lbl_age.text = String(profile.age)
        lbl_shortid.text = "ID : \(globalData.shortid)"
        lbl_party_cnt.makeLable(string1: profile.party_cnt, string2: "\n聚會")
        lbl_like_cnt.makeLable(string1: profile.like_cnt, string2: "\n人氣")
        lbl_follower_cnt.makeLable(string1: profile.follower_cnt, string2: "\n粉絲人數")
        lbl_follow_cnt.makeLable(string1: profile.follow_cnt, string2: "\n追蹤中")
        setupFrame()
    }
    
    func setupTopStyle() {
        lbl_vip.font = .systemFont(ofSize: 15)
        lbl_vip.textAlignment = .center
        lbl_vip.textColor = .white
        lbl_vip.layer.masksToBounds = true
        lbl_username.font = .boldSystemFont(ofSize: 16)
        lbl_gender.tintColor = .black
        lbl_gender.font = .boldSystemFont(ofSize: 16)
        lbl_age.font = .boldSystemFont(ofSize: 16)
        lbl_shortid.textColor = Colors.rgb149Gray
    }
    
    @objc func reload_photo() {
        DownloadImage(view: img_user, img: globalData.user_img, id: "", placeholder:  UIImage(named: "user.png"))
    }
    
    @objc func updateUser(_ sender: Any) {
        hideMainBar()
        let vc = storyboard?.instantiateViewController(withIdentifier: "UpdateUserVC") as! UpdateUserVC
        vc.profile = profile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func refresh() {
        callProfileService(refresh: true)
    }
    
    @objc func goFollowerPage() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserListCell") as! UserListTableVC
        vc.from = "follower"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goFollowingPage() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserListCell") as! UserListTableVC
        vc.from = "following"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goMyPost() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyPostTbV") as! MyPostTbV
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goMyParty() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyPartyTbV") as! MyPartyTbV
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if titleArray[indexPath.row] == "關於我" {
            return 135
        } else if titleArray[indexPath.row] == "個性" {
            return 64
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell", for: indexPath) as! MyProfileCell
        let tmp = titleArray[indexPath.row]
        cell.selectionStyle = .none
        cell.init_profile(title: tmp, user_info: profile.user_info, job_name: profile.job_name, bloodtype: profile.bloodtype, personality_name: profile.personality_name, width: self.view.frame.width)
        return cell
    }
}
