//
//  Jo_FullPostView.swift
//  join
//
//  Created by 連亮涵 on 2020/6/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Agrume
import Cosmos

class Jo_FullPostView: UIView,ChatBoardSegmentedControlDelegate {
        
    let v_post = UIView()
    let v_user = UIView()
    let lbl_username = UILabel()
    
    let btn_share = UIButton()
    let imageView = UIImageView()
    let v_line = UIView()
    let v_line3 = UIView()
    let v_line4 = UIView()
    let lbl_starttime_literal = UILabel()
    let lbl_cutofftime_literal = UILabel()
    let lbl_adress_literal = UILabel()
    let lbl_starttime = UILabel()
    let lbl_cutofftime = UILabel()
    let lbl_adress = UILabel()
    let btn_signUp = UIButton()
    let btn_actionList = UIButton()
    let img_starttime = UIImageView(image: UIImage(named: "baseline_date_range_black_48pt"))
    let img_cutofftime = UIImageView (image: UIImage(named: "baseline_query_builder_black_24pt"))
    let img_adress = UIImageView(image: UIImage(named: "baseline_place_black_48pt"))
    let img_budgettype = UIImageView(image: UIImage(named: "baseline_credit_card_black_48pt"))
    let img_budget = UIImageView(image: UIImage(named: "baseline_attach_money_black_48pt"))
    let img_attendance = UIImageView(image: UIImage(named: "baseline_people_black_48pt"))
    let lbl_Budgettype = UILabel()
    let lbl_budget = UILabel()
    let lbl_attendance = UILabel()
    let lbl_partyInfo = UILabel()
    let txt_postText = UITextView()
    let v_hit = UIView()
    let lbl_hit = UILabel()
    
    let img_userIcon = UIImageView()
    
    let v_segment = CustomSegmentedButtons()
    
    let activityIndicater = MyActivityIndicatorView()
    
    let v_stars: CosmosView = {
        let v = CosmosView()
        v.settings.updateOnTouch = false
        v.settings.filledImage = ratingStar.fill_18pt
        v.settings.emptyImage = ratingStar.empty_18pt
        v.settings.fillMode = .precise
        v.settings.starSize = 15
        
        v.settings.textColor = Colors.friendRed
        v.settings.textMargin = 10
        v.settings.textFont = .systemFont(ofSize: 20)
        return v
    }()
    
    var fullPost = Party()
    var participant_arry: [AttendanceList] = []
    
    var uid = ""
    var ptid = ""
    var receipt = ""
    
    func setPostData(ptid: String,
                     uid: String,
                     fullPost:Party,
                     participant_arry: [AttendanceList],
                     width: CGFloat)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(back), name: NSNotification.Name(rawValue: "back"), object: nil)
        self.ptid = ptid
        self.uid = uid
        self.participant_arry = participant_arry
        self.fullPost = fullPost
        self.frame = CGRect(x:0,y:0,width: width,height: 1000)
        self.backgroundColor = .white
        //設定主要貼文區域
        v_post.frame = CGRect(x:0,y:0,width: width,height: 500)
        self.addSubview(v_post)
        //
        v_user.frame = CGRect(x: 0, y: 0, width: width, height: 85)
        v_user.backgroundColor = .white
        v_post.addSubview(v_user)
        //設定頭像
        img_userIcon.frame = CGRect(x:15,y:20,width: 45,height: 45)
        img_userIcon.configureUserIcon(target: self, cornerRadious: 22.5, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: fullPost.user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        v_user.addSubview(img_userIcon)
        //設定暱稱
        lbl_username.frame = CGRect(x:72, y:24, width: 200, height: 20)
        lbl_username.text = fullPost.username
        lbl_username.font = .boldSystemFont(ofSize: 18)
        lbl_username.textColor = UIColor.black
        lbl_username.sizeToFit()
        v_user.addSubview(lbl_username)
        //設定評價
        v_stars.frame = CGRect(x: 72, y: below(lbl_username) + 5, width: 200, height: 20)
        v_stars.rating = Double(fullPost.avgStarRating)!
        v_stars.text = fullPost.avgStarRating
        v_user.addSubview(v_stars)
        //設定圖片
        imageView.frame = CGRect(x:0, y: below(v_user), width: width, height: width)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tap)
        DownloadImage(view: imageView, img: fullPost.img_url, id: "ptid:" + ptid, placeholder: nil)
        v_post.addSubview(imageView)
        //
        v_hit.frame = CGRect(x: self.frame.width - 147, y: imageView.frame.height - 46, width: 147, height: 36)
        if #available(iOS 11.0, *) {
            v_hit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        v_hit.layer.cornerRadius = 18
        v_hit.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        imageView.addSubview(v_hit)
        lbl_hit.frame = CGRect(x: 18, y: 8, width: v_hit.frame.width, height: 20)
        lbl_hit.font = .systemFont(ofSize: 14)
        lbl_hit.text = "瀏覽次數 : " + fullPost.hitCount
        lbl_hit.textColor = .white
        v_hit.addSubview(lbl_hit)
        //設定文字
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        txt_postText.frame = CGRect(x: 15, y: below(imageView) + 15, width: width - 110, height: 50)
        txt_postText.attributedText = NSAttributedString(string: fullPost.title, attributes:attributes)
        txt_postText.textAlignment = .natural
        txt_postText.font = .boldSystemFont(ofSize: 17)
        txt_postText.textContainerInset = .zero
        txt_postText.textContainer.lineFragmentPadding = 0
        txt_postText.textColor = UIColor.black.withAlphaComponent(1)
        txt_postText.translatesAutoresizingMaskIntoConstraints = true
        txt_postText.isScrollEnabled = false
        txt_postText.isEditable = false
        v_post.addSubview(txt_postText)
        //
        btn_share.frame = CGRect(x: (self.frame.width - 300)/2, y: below(txt_postText) + 12, width: 140, height: 40)
        btn_share.layer.cornerRadius = 20
        btn_share.layer.borderColor = Colors.themePurple.cgColor
        btn_share.layer.borderWidth = 1
        btn_share.setTitle("分享", for: .normal)
        btn_share.setTitleColor(Colors.themePurple, for: .normal)
        btn_share.addTarget(self, action: #selector(tapShare), for: .touchDown)
        v_post.addSubview(btn_share)
        //分隔線
        v_line.frame = CGRect(x:0, y: below(btn_share) + 10, width: width, height: 0.5)
        v_line.backgroundColor = .lightGray
        v_post.addSubview(v_line)
        //
        img_starttime.frame = CGRect(x: 17, y: below(v_line) + 10, width: 12, height: 12)
        img_starttime.tintColor = Colors.rgb149Gray
        v_post.addSubview(img_starttime)
        //
        img_cutofftime.frame = CGRect(x: 17, y: below(img_starttime) + 18, width: 12, height: 12)
        img_cutofftime.tintColor = Colors.rgb149Gray
        v_post.addSubview(img_cutofftime)
        //
        img_adress.frame = CGRect(x: 17, y: below(img_cutofftime) + 19, width: 12, height: 12)
        img_adress.tintColor = Colors.rgb149Gray
        v_post.addSubview(img_adress)
        //
        lbl_starttime_literal.text = "活動時間"
        lbl_starttime_literal.textColor = Colors.rgb149Gray
        lbl_starttime_literal.font = .systemFont(ofSize: 15)
        lbl_starttime_literal.frame = CGRect(x: after(img_starttime) + 8.5, y: below(v_line) + 6, width: 100, height: 20)
        v_post.addSubview(lbl_starttime_literal)
        //
        lbl_cutofftime_literal.text = "報名截止日"
        lbl_cutofftime_literal.textColor = Colors.rgb149Gray
        lbl_cutofftime_literal.font = .systemFont(ofSize: 15)
        lbl_cutofftime_literal.frame = CGRect(x: after(img_cutofftime) + 8.5, y: below(v_line) + 35, width: 100, height: 20)
        v_post.addSubview(lbl_cutofftime_literal)
        //
        lbl_adress_literal.text = "活動地點"
        lbl_adress_literal.textColor = Colors.rgb149Gray
        lbl_adress_literal.font = .systemFont(ofSize: 15)
        lbl_adress_literal.frame = CGRect(x: img_adress.frame.origin.x + img_adress.frame.width + 8.5, y: img_cutofftime.frame.origin.y + img_cutofftime.frame.height + 16, width: 100, height: 20)
        v_post.addSubview(lbl_adress_literal)
        //
        lbl_starttime.frame = CGRect(x: width - 170 , y: below(v_line) + 6, width: 170, height: 20)
        lbl_starttime.text = changeformat2(string: fullPost.starttime, part: "all")
        lbl_starttime.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1)
        lbl_starttime.font = .systemFont(ofSize: 16)
        v_post.addSubview(lbl_starttime)
        //
        lbl_cutofftime.frame = CGRect(x:  width - 170, y: below(v_line) + 35, width: 170, height: 20)
        lbl_cutofftime.text = changeformat2(string: fullPost.cutofftime, part: "all")
        lbl_cutofftime.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1)
        lbl_cutofftime.font = .systemFont(ofSize: 16)
        v_post.addSubview(lbl_cutofftime)
        //
        lbl_adress.frame = CGRect(x: width - 235, y: below(img_cutofftime) + 18, width: 220, height: 40)
        lbl_adress.text = fullPost.address
        lbl_adress.textColor = Colors.themePurple
        lbl_adress.textAlignment = .right
        lbl_adress.font = .systemFont(ofSize: 16)
        lbl_adress.numberOfLines = 2
        lbl_adress.isUserInteractionEnabled = true
        v_post.addSubview(lbl_adress)
        let adressTap = UITapGestureRecognizer.init(target: self, action: #selector(showMap))
        lbl_adress.addGestureRecognizer(adressTap)
        //分隔線
        v_line3.frame = CGRect(x:0,y: below(lbl_adress) + 10, width: width ,height: 0.5)
        v_line3.backgroundColor = .lightGray
        v_post.addSubview(v_line3)
        //人數
        img_attendance.tintColor =  Colors.themePurple
        img_attendance.frame = CGRect(x: 21 , y: v_line3.frame.origin.y + 10 , width: 22, height: 22)
        v_post.addSubview(img_attendance)
        //
        lbl_attendance.frame = CGRect(x: after(img_attendance) + 6 ,y: v_line3.frame.origin.y + 12, width: 70,height: 20)
        lbl_attendance.font = .systemFont(ofSize: 15)
        lbl_attendance.textColor = .black
        lbl_attendance.text = fullPost.attendance
        v_post.addSubview(lbl_attendance)
        //付款方式
        img_budgettype.tintColor =  Colors.themePurple
        img_budgettype.frame = CGRect(x: after(lbl_attendance) + 10 , y: v_line3.frame.origin.y + 11, width: 22, height: 22)
        v_post.addSubview(img_budgettype)
        //
        lbl_Budgettype .frame = CGRect(x: after(img_budgettype) + 6 , y:v_line3.frame.origin.y + 11 ,width: 45,height: 20)
        lbl_Budgettype.font = .systemFont(ofSize: 15)
        lbl_Budgettype.textColor = .black
        lbl_Budgettype.text = fullPost.budgettype
        lbl_Budgettype.sizeToFit()
        lbl_Budgettype.frame.size.height = 20
        v_post.addSubview(lbl_Budgettype)
        //價格
        img_budget.frame = CGRect(x: after(lbl_Budgettype) + 25, y: v_line3.frame.origin.y + 11, width: 22, height: 22)
        img_budget.tintColor = Colors.themePurple
        v_post.addSubview(img_budget)
        //
        lbl_budget.frame = CGRect(x: after(img_budget) + 3 ,y: v_line3.frame.origin.y + 12, width: 110,height: 20)
        lbl_budget.font = .systemFont(ofSize: 15)
        lbl_budget.textColor = .black
        lbl_budget.text = fullPost.budget
        v_post.addSubview(lbl_budget)
        //分隔線
        v_line4.frame = CGRect(x:0,y: below(img_attendance) + 10, width: width ,height: 0.5)
        v_line4.backgroundColor = .lightGray
        v_post.addSubview(v_line4)
        //詳細資料
        lbl_partyInfo.frame = CGRect(x: 16 , y: v_line4.frame.origin.y + 10  , width: width - 20, height: 300)
        lbl_partyInfo.numberOfLines = 100
        lbl_partyInfo.text = fullPost.party_info
        lbl_partyInfo.sizeToFit()
        v_post.addSubview(lbl_partyInfo)
        //
        btn_signUp.frame = CGRect(x: after(btn_share) + 20, y: below(txt_postText) + 12, width: 140, height: 40)
        switch fullPost.isJoin {
        case "0":
            if fullPost.isExpired == "1" {
                btn_signUp.isHidden = true
                btn_share.isHidden = true
            } else {
                btn_signUp.setTitle("取消報名", for: .normal)
            }
        case "1": // v
            btn_signUp.isHidden = false
            btn_share.isHidden = false
            btn_signUp.setTitle("其他功能", for: .normal)
        case "2": //v
            if fullPost.isExpired == "1" {
                btn_signUp.isHidden = true
                btn_share.isHidden = true
            } else {
                if fullPost.isCutOff == "1" {
                    btn_signUp.isHidden = true
                    btn_share.isHidden = true
                }
                btn_signUp.setTitle("報名", for: .normal)
            }
        case "3":
            if fullPost.isExpired == "1" {
                btn_signUp.isHidden = true
                btn_share.isHidden = true
            } else {
                if fullPost.isCutOff == "1" {
                    btn_signUp.isHidden = true
                    btn_share.isHidden = true
                }
                btn_signUp.setTitle("報名", for: .normal)
            }
        default:
            break
        }
        
        if fullPost.isAllow == "0" {
            btn_signUp.setTitle("無法報名", for: .normal)
            btn_signUp.isEnabled = false
        }

        if fullPost.isHost == "1" {
            btn_signUp.isHidden = true
            btn_share.isHidden = false
        } else {
            btn_actionList.isHidden = true
        }
    
        btn_signUp.addTarget(self, action: #selector(btnTap), for: .touchDown)
        btn_signUp.setTitleColor(.white ,for: .normal)
        btn_signUp.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_signUp.frame.height/2)
        btn_signUp.layer.cornerRadius = btn_signUp.frame.height / 2
        v_post.addSubview(btn_signUp)
        //
        btn_actionList.frame = CGRect(x: after(btn_share) + 20, y: below(txt_postText) + 12, width: 140, height: 40)
        btn_actionList.setTitle("功能列", for: .normal)
        btn_actionList.setTitleColor(.white ,for: .normal)
        btn_actionList.layer.cornerRadius = btn_actionList.frame.height/2
        btn_actionList.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_actionList.frame.height/2)
        btn_actionList.addTarget(self, action: #selector(actionListTap), for: .touchDown)
        v_post.addSubview(btn_actionList)
        //
        v_segment.frame = CGRect(x: 15, y: below(lbl_partyInfo) + 40, width: 200, height: 30)
        v_segment.setButtonTitles(buttonTitles: ["公開留言板", "團員留言板"])
        v_segment.delegate = self
        v_post.addSubview(v_segment)
        //
        self.addSubview(activityIndicater)
        activityIndicater.center = self.center
        activityIndicater.frame.origin.y -= 150
        //重新設定高度
        self.frame = CGRect(x: 0, y: 0, width: width, height: v_segment.frame.origin.y + v_segment.frame.height + 15)
        v_post.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
    }
    
    func change(to index: Int) {
        if index == 0 {
            (self.findViewController() as! Jo_FullPostVC).isPublic = "1"
            (self.findViewController() as! Jo_FullPostVC).getPartyComt(refresh: false, scrollBottom: false, loadmore: false)
            
            (self.findViewController() as! Jo_FullPostVC).txt_Input.text = ""
            (self.findViewController() as! Jo_FullPostVC).txt_Input.resignFirstResponder()
        } else {
            
            (self.findViewController() as! Jo_FullPostVC).txt_Input.text = ""
            (self.findViewController() as! Jo_FullPostVC).txt_Input.resignFirstResponder()
            
            if fullPost.isJoin != "1" , fullPost.isHost != "1" {
                Alert.notAllowChatBoardAlert(vc: self.findViewController()!)
                (self.findViewController() as! Jo_FullPostVC).clearComments()
            } else {
                (self.findViewController() as! Jo_FullPostVC).isPublic = "0"
                (self.findViewController() as! Jo_FullPostVC).getPartyComt(refresh: false, scrollBottom: false, loadmore: false)
            }
        }
    }
    
    func callCancelPartyService() {
        let request = createHttpRequest(Url: globalData.CancelPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(self.ptid)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        (self.findViewController() as! Jo_FullPostVC).refresh()
                        shortInfoMsg(msg: "取消報名成功", vc: self.findViewController()!, sec: 2)
                    }
                    else if responseJSON["code"] as! Int == 135
                    {
                        shortInfoMsg(msg: "你已被審核通過", vc: self.findViewController()!, sec: 2)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                    }
                }
            }
        }
        task.resume()
    }

    func callSignUpService() {
        let request = createHttpRequest(Url: globalData.ApplyPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        Alert.successSendPartyAlert(view: self)
                    }
                    else if responseJSON["code"] as! Int == 132
                    {
                        Alert.fullPartyAlert(view: self)
                    }
                    else if responseJSON["code"] as! Int == 131
                    {
                        Alert.buyVIPAlert(vc: self.findViewController()!, title: "無限報名活動", msg: "一般會員同時間可參加兩個活動，升級鑽石VIP可盡情參加活動不限次數。", from: "參加活動")
                    }
                    else if responseJSON["code"] as! Int == 100131
                    {
                        self.checkSuscription()
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String

                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.findViewController()?.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                    }
                }
            }
        }
        task.resume()
    }
    
    func callRegretService(statusmemo: String) {
        if ptid != ""
        {
            let request = createHttpRequest(Url: globalData.RegretPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&statusmemo=\(statusmemo)")
    
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else
                {
                    Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]
                {
                    DispatchQueue.main.async {
                        if  responseJSON["code"] as! Int == 0
                        {
                            (self.findViewController() as! Jo_FullPostVC).refresh()
                            shortInfoMsg(msg: "取消報名成功", vc: self.findViewController()!, sec: 2)
                        }
                        else if responseJSON["code"] as! Int == 136
                        {
                            (self.findViewController() as! Jo_FullPostVC).refresh()
                            shortInfoMsg(msg: "主辦者已取消你的出席", vc: self.findViewController()!, sec: 2)
                        }
                        else if responseJSON["code"] as! Int == 139
                        {
                            shortInfoMsg(msg: "無法出席須在活動時間24小時前才可使用", vc: self.findViewController()!, sec: 2)
                        }
                        else
                        {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func deleteParty() {
        NetworkManager.shared.callDeletPartyService(ptid: ptid) { (code, msg) in
            switch code {
            case 0:
                (self.findViewController() as! Jo_FullPostVC).backtoHome(0)
            case 134:
                Alert.failDeletePartyAlert(vc: self.findViewController()!)
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self.findViewController()!)
            }
        }
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
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                self.activityIndicater.inactive()
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self.findViewController()!)
                self.activityIndicater.inactive()
            }
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let img = imageView.image
        if img != nil {
            let agrume = Agrume(image: img!, background: .blurred(.dark), dismissal: .withButton(.none))
            let vc = self.findViewController() as! Jo_FullPostVC
            vc.txt_Input.resignFirstResponder()
            agrume.show(from: vc)
        }
    }
        
    @objc func back() {
        (self.findViewController() as! Jo_FullPostVC).backtoHome(0)
    }
    
    @objc func showMap() {
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {  //if phone has an app
            let url = URL(string: "comgooglemaps://?q=\(fullPost.address.urlEncoded())")
            UIApplication.shared.open(url!)
        } else {
            //Open in browser
            let url = URL(string: "https://www.google.co.in/maps/?q=\(fullPost.address.urlEncoded())")
            UIApplication.shared.open(url!)
        }
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(separAdress[1]) { (placemarks, error) in
//            if error != nil {
//                print("1")
//            } else if let placemarks = placemarks {
//                if let coordinate = placemarks.first?.location?.coordinate {
//
//                }
//            }
//        }
    }
    
    @objc func showUser() {
        (findViewController() as! Jo_FullPostVC).endEdit()
        let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = self.uid
        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapShare() {
        let defaultText = "https://www.bc9in.com/web/party.html?ptid=\(ptid)"
        let activity = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
        self.findViewController()?.present(activity, animated: true, completion: nil)
    }
    
    @objc func actionListTap() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //
        let partyListAction = UIAlertAction(title: "待審核、出席名單", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ListsVC") as! ListsVC
            vc.ptid = self.ptid
            vc.isAllow = self.fullPost.isAllow
            vc.isExpired = self.fullPost.isExpired
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        })
        //
        let updatePartyAction = UIAlertAction(title: "修改聚會", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "JoPostVC") as! Jo_PostVC
            vc.fullPost = self.fullPost
            vc.isUpdate = true
            vc.ptid = self.ptid
            self.findViewController()?.present(vc, animated: true, completion: nil)
        })
        //
        let groupBoardAction = UIAlertAction(title: "團員留言版", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "GroupChatBoardVC") as! GroupChatBoardVC
            vc.ptid = self.ptid
            vc.uid = self.uid
            vc.username = self.fullPost.username
            vc.user_img = self.fullPost.user_img
            vc.participant_arry = self.participant_arry
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        })
        //
        let deletPartyAction = UIAlertAction(title: "刪除聚會", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
            let alertController = UIAlertController(title: "刪除聚會", message: "確定刪除此聚會? 刪除就無法恢復囉!。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default){(UIAlertAction) in
                    self.deleteParty()
                }
            alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title:"再想想",style: .cancel)
            alertController.addAction(cancelAction)
            //顯示提示框
            self.findViewController()?.present(alertController, animated: true, completion: nil)
        })
        //
        let goListAction = UIAlertAction(title: "出席名單與評分", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ParticipantsListTbV") as! ParticipantsListTbV
            vc.ptid = self.ptid
            vc.isHost = false
            vc.isExpired = self.fullPost.isExpired
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        })
        
        optionMenu.addAction(groupBoardAction)
        optionMenu.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        if fullPost.isExpired == "1" {
            optionMenu.addAction(goListAction)
        } else {
            optionMenu.addAction(partyListAction)
            optionMenu.addAction(updatePartyAction)
            optionMenu.addAction(deletPartyAction)
        }
        
        self.findViewController()?.present(optionMenu,animated: true, completion: nil)
    }
    
    @objc func btnTap()
    {
        switch fullPost.isJoin {
        case "0":
            Alert.basicActionAlert(vc: self.findViewController()!, title: "取消報名", message: "確定取消報名此活動?", okBtnTitle: "確定", twoBtn: true) { (_) in
                self.callCancelPartyService()
            }
        case "1":
            //2選1選單
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            //
            let typeHandler = { (action:UIAlertAction!) -> Void in
                let typeMessage = UIAlertController(title: "無法出席", message: "請輸入其他無法出席原因。", preferredStyle: .alert)
                typeMessage.addTextField { (textField) in
                    textField.placeholder = "必填，限50個字元內"
                }
                typeMessage.addAction(UIAlertAction(title: "送出", style: .default, handler: {(action:UIAlertAction!) -> Void in
                    let reason = typeMessage.textFields?[0].text
                    self.callRegretService(statusmemo: reason!)
                }))
                typeMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.findViewController()?.present(typeMessage,animated: true, completion: nil)
            }
            //
            let reasonHandler = { (action:UIAlertAction!) -> Void in
                let alertMessage = UIAlertController(title: "無法出席", message: "好可惜，請將無法出席的原因通知一下辛苦的主辦人，謝謝!", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "臨時有事", style: .default, handler: {(action:UIAlertAction!) -> Void in
                    self.callRegretService(statusmemo: "臨時有事")
                }))
                alertMessage.addAction(UIAlertAction(title: "其他原因", style: .default, handler: typeHandler))
                alertMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.findViewController()?.present(alertMessage,animated: true, completion: nil)
            }
            //
            var goListActionTitle = "出席名單"
            if fullPost.isExpired == "1" { goListActionTitle = "出席名單與評分" }
            let goListAction = UIAlertAction(title: goListActionTitle, style: .default, handler: {(action:UIAlertAction!) -> Void in
                let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ParticipantsListTbV") as! ParticipantsListTbV
                vc.ptid = self.ptid
                vc.isHost = false
                if self.fullPost.isExpired == "1" { vc.isExpired = self.fullPost.isExpired }
                self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
                })
            //
            let goGroupAction = UIAlertAction(title: "團員版", style: .default, handler: {(action:UIAlertAction!) -> Void in
                let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "GroupChatBoardVC") as! GroupChatBoardVC
                vc.ptid = self.ptid
                vc.uid = self.uid
                vc.username = self.fullPost.username
                vc.user_img = self.fullPost.user_img
                self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
                })
            //
            let regretPartyAction = UIAlertAction(title: "無法出席(限24小時之前)", style: .default, handler: reasonHandler)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            //
            if fullPost.isExpired != "1" {
                optionMenu.addAction(regretPartyAction)
                optionMenu.addAction(goGroupAction)
            }
            optionMenu.addAction(goListAction)
            optionMenu.addAction(cancelAction)
            self.findViewController()?.present(optionMenu,animated: true, completion: nil)
        case "2":
            callSignUpService()
        case "3":
            callSignUpService()
        default:
            break
        }
    }
}
