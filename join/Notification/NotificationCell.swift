//
//  NotificationCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/30.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    let img_user = UIImageView()
    let lbl_text = UILabel()
    let lbl_time = UILabel()
    
    var serial_no = ""
    var callapi = ""
    var uid = ""
    var pid = ""
    var ptid = ""
    var isPublic = ""
    //聊天室需求
    var chtid = ""
    var senduid = ""
    var friend_img_url = ""
    var friend_shortid = ""
    var friendname = ""
    var cmtid = ""
    var likeArray:[QueryLikeMe] = [QueryLikeMe]()
    var username = ""
    var memo_img_url = ""

    func init_notification(serial_no: String,
                           uid: String,
                           img_url: String,
                           text: String,
                           time: String,
                           callapi: String,
                           isRead: String,
                           pid: String,
                           ptid: String,
                           senduid: String,
                           cmtid: String,
                           isPublic: String,
                           username: String,
                           memo_img_url: String,
                           width: CGFloat)
    {
        self.serial_no = serial_no
        self.callapi = callapi
        self.friend_img_url = img_url
        self.uid = uid
        
        self.senduid = senduid
        self.pid = pid
        self.ptid = ptid
        self.cmtid = cmtid
        self.isPublic = isPublic
        self.username = username
        self.memo_img_url = memo_img_url
        //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: time)
        let pickDate = Int(date!.timeIntervalSinceNow)
        if pickDate >= -3600 {
            lbl_time.text = "\(Int(-pickDate/60) + 1)分鐘前"
        } else if pickDate >= -86400 {
            lbl_time.text = "\(Int(-pickDate/3600) + 1)小時前"
        } else {
            lbl_time.text = "\(Int(-pickDate/86400) + 1)天前"
        }
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tap)
        //
        img_user.frame = CGRect(x: 15, y: 21, width: 40, height: 40)
        img_user.layer.masksToBounds = true
        img_user.contentMode = .scaleAspectFill
        img_user.layer.cornerRadius = img_user.frame.height/2
        DownloadImage(view: img_user, img: img_url, id: "", placeholder: nil)
        self.addSubview(img_user)
        //
        lbl_text.frame = CGRect(x: 65, y: 21, width: width - 65 - 15, height: 38)
        lbl_text.text = text
        lbl_text.font = .systemFont(ofSize: 14)
        lbl_text.numberOfLines = 2
        lbl_text.sizeToFit()
        self.addSubview(lbl_text)
        //
        lbl_time.frame = CGRect(x: 65, y: 58, width: 60, height: 14)
        lbl_time.font = .systemFont(ofSize: 12)
        lbl_time.textColor = Colors.rgb149Gray
        self.addSubview(lbl_time)
    }

    func callProfileService(){
       
        let request = createHttpRequest(Url: globalData.QueryUser_MyPageUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\(self.uid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let file = responseJSON["list"] as? [[String: Any]] {
                            self.friend_shortid = file[0]["shortid"] as! String
                            self.friendname = file[0]["username"] as! String
                        }
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
    
    func callReadNotifyService()
    {
        let request = createHttpRequest(Url: globalData.ReadNotifyUrl, HttpType: "POST", Data: "token=\(globalData.token)&serial_no=\(self.serial_no)")
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
                        self.backgroundColor = .white
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "redDot"), object: nil)
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
    
    func callQueryLikeMEService() {
        let request = createHttpRequest(Url: globalData.QueryLikeMeUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(0)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                if responseJSON["code"] as! Int == 0
                {
                    DispatchQueue.main.async {
                        self.likeArray.removeAll()
                        for like in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpLike = QueryLikeMe()
                            parseQueryLikeMe(querylikeme: tmpLike, like: like)
                            self.likeArray.append(tmpLike)
                        }
                    }
                }
                else
                {
                    ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                }
            }
        }
        task.resume()
    }
    
    @objc func tapped()
    {
        callReadNotifyService()
        switch self.callapi {
        case "queryuser_mypage":
            let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            userInfoVC.uid = senduid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        case "getpost":
            let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Pi_FullPostNavi") as! Pi_FullPostNavi
            Navi.pid = pid
            Navi.uid = senduid
            self.findViewController()!.present(Navi, animated: true, completion: nil)
        case "getPostComtDetail":
            let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Pi_FullPostNavi") as! Pi_FullPostNavi
            Navi.pid = pid
            Navi.cmtid = cmtid
            Navi.scrolltoComt = true
            self.findViewController()!.present(Navi, animated: true, completion: nil)
        case "getparty":
            let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
            Navi.ptid = ptid
            Navi.uid = senduid
            self.findViewController()!.present(Navi, animated: true, completion: nil)
        case "getPartyComtDetail":
            if isPublic == "0" {
                NetworkManager.shared.callCheckUserAttendanceService(ptid: ptid, atUid: uid) { [self] (code, msg) in
                    switch code {
                    case 0:
                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "GroupChatBoardVC") as! GroupChatBoardVC
                        vc.ptid = self.ptid
                        vc.uid = senduid
                        vc.username = username
                        vc.user_img = memo_img_url
                
                        vc.scrollCmtid = cmtid
                        vc.scrolltoComt = true
                        vc.from = "notification"
                        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
                    case 149:
                        Alert.atPersonLeavePartyAlert(vc: findViewController()!, username: "您")
                    default:
                        break
                    }
                }
            } else {
                let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
                Navi.ptid = ptid
                Navi.cmtid = cmtid
                Navi.scrolltoComt = true
                self.findViewController()!.present(Navi, animated: true, completion: nil)
            }
        case "getUnreviewedList":
            let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "ApplierListTbV") as! ApplierListTbV
            vc.ptid = self.ptid
            vc.callGetUnreviewedListService()
            self.findViewController()?.hideMainBar()
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "getAttendanceList":
            let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "ParticipantsListTbV") as! ParticipantsListTbV
            vc.isHost = false
            vc.ptid = self.ptid
            vc.isExpired = "1"
            self.findViewController()?.hideMainBar()
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ContactVC") as! ContactVC
            self.findViewController()!.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
