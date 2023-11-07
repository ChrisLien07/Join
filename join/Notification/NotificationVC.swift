//
//  NotificationVC.swift
//  join
//
//  Created by ChrisLien on 2020/11/30.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController, ChatBoardSegmentedControlDelegate {

    @IBOutlet weak var v_segmentBtn: CustomSegmentedButtons!
    @IBOutlet weak var tbv_main: UITableView!
    
    var notification_array:[Notify]=[Notify]()
    var from = "all"
    var currentType = "Post"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv_main.delegate = self
        tbv_main.dataSource = self
        createObservers()
        setupAnchor()
        configure_segmentBtns()
        callGetNotifyListService(type: "Post")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMainBar()
    }
    
    func configure_segmentBtns() {
        v_segmentBtn.setButtonTitles(buttonTitles: ["隨手拍", "揪一起", "公告", "歷史紀錄"])
        v_segmentBtn.delegate = self
        self.view.addSubview(v_segmentBtn)
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationQueryuser), name: userNotifications.queryuser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationGetPost), name: userNotifications.getpost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationGetParty), name: userNotifications.getparty, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationGetUnreviewedList), name: userNotifications.getUnreviewedList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationGetAttendanceList), name: userNotifications.getAttendanceList, object: nil)
    }
    
    func change(to index: Int) {
        switch index {
        case 0:
            currentType = "Post"
            callGetNotifyListService(type: "Post")
        case 1:
            currentType = "Party"
            callGetNotifyListService(type: "Party")
        case 2:
            currentType = "Announce"
            callGetNotifyListService(type: "Announce")
        case 3:
            currentType = "History"
            callGetNotifyListService(type: "History")
        default:
            break
        }
    }
    
    func callGetNotifyListService(type: String)
    {
        let request = createHttpRequest(Url: globalData.GetNotifyListUrl, HttpType: "POST", Data: "token=\(globalData.token)&type=\(type)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                if responseJSON["code"] as! Int == 0
                {
                    DispatchQueue.main.async {
                        self.notification_array.removeAll()
                        for note in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpNotify = Notify()
                            parseNotify(notify: tmpNotify, note: note)
                            let tmpMemoJson = note["notify_memo_json"] as? [String: Any] ?? ["":""]
                            for tmpMemo in tmpMemoJson {
                                switch tmpMemo.key {
                                case "uid":
                                    let memo = tmpMemo.value as? String ?? ""
                                    tmpNotify.senduid = memo
                                case "pid":
                                    let memo = tmpMemo.value as! String
                                    tmpNotify.pid = memo
                                case "ptid":
                                    let memo = tmpMemo.value as! String
                                    tmpNotify.ptid = memo
                                case "cmtid":
                                    let memo = tmpMemo.value as? String ?? ""
                                    tmpNotify.cmtid = memo
                                case "isPublic":
                                    let memo = tmpMemo.value as? String ?? ""
                                    tmpNotify.isPublic = memo
                                case "img_url":
                                    let memo = tmpMemo.value as? String ?? ""
                                    tmpNotify.memo_img_url = memo
                                case "username":
                                    let memo = tmpMemo.value as? String ?? ""
                                    tmpNotify.username = memo
                                default:
                                    break
                                }
                            }
                            self.notification_array.append(tmpNotify)
                        }
                        self.tbv_main.reloadData()
                    }
                }
                else if responseJSON["code"] as! Int == 127
                {
                    DispatchQueue.main.async {
                        self.notification_array.removeAll()
                        self.tbv_main.reloadData()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func readAllNotify() {
        NetworkManager.shared.callReadAllNotifyService { (code, msg) in
            switch code {
            case 0:
                self.callGetNotifyListService(type: self.currentType)
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
    
    func setupAnchor() {
        v_segmentBtn.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 50))
        tbv_main.anchor(top: v_segmentBtn.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    @IBAction func readAll(_ sender: Any) {
        self.tabBarController?.tabBar.items![1].badgeValue = nil
        readAllNotify()
    }
    
    //MARK: - 推播相關
   
    @objc func userNotificationQueryuser(_ notification: Notification) {
        
        guard let uid = notification.userInfo?["uid"] as? String else { return }
        let otherReason   = notification.userInfo?["otherReason"] as? String ?? ""
        
        if let vc = self.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            vc.uid = uid
            if otherReason != "" { Alert.basicAlert(vc: vc, title: "無法出席通知", message: "原因: \(otherReason)") }
            self.hideMainBar()
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc func userNotificationGetPost(_ notification: Notification) {
        
        guard let pid = notification.userInfo?["pid"] as? String else { return }
        
        let uid   = notification.userInfo?["uid"] as? String ?? ""
        let cmtid = notification.userInfo?["cmtid"] as? String ?? ""
        let scroll = notification.userInfo?["scroll"] as? String ?? "0"
        
        let Navi = self.storyboard!.instantiateViewController(withIdentifier: "Pi_FullPostNavi") as! Pi_FullPostNavi
        Navi.pid = pid
        Navi.uid = uid
        Navi.cmtid = cmtid
        if scroll == "1" { Navi.scrolltoComt = true }
        present(Navi, animated: false, completion: nil)
    }
    
    @objc func userNotificationGetParty(_ notification: Notification) {
        
        guard let ptid = notification.userInfo?["ptid"] as? String else { return }
        
        let uid   = notification.userInfo?["uid"] as? String ?? ""
        let cmtid = notification.userInfo?["cmtid"] as? String ?? ""
        let isPublic = notification.userInfo?["isPublic"] as? String ?? ""
        let scroll = notification.userInfo?["scroll"] as? String ?? "0"
        
        if isPublic == "0" {
            let username = notification.userInfo?["username"] as? String ?? ""
            let userIcon = notification.userInfo?["userIcon"] as? String ?? ""
            let myUid = notification.userInfo?["myUid"] as? String ?? ""
            
            NetworkManager.shared.callCheckUserAttendanceService(ptid: ptid, atUid: myUid) { [self] (code, msg) in
                switch code {
                case 0:
                    let vc = storyboard?.instantiateViewController(withIdentifier: "GroupChatBoardVC") as! GroupChatBoardVC
                    vc.ptid = ptid
                    vc.username = username
                    vc.user_img = userIcon
                    vc.uid = uid
                    vc.scrollCmtid = cmtid
                    if scroll == "1" { vc.scrolltoComt = true }
                    vc.from = "notification"
                    self.navigationController?.pushViewController(vc, animated: true)
                case 149:
                    Alert.atPersonLeavePartyAlert(vc: findViewController()!, username: "您")
                default:
                    break
                }
            }
        } else {
            let Navi = storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
            Navi.ptid = ptid
            Navi.uid = uid
            Navi.cmtid = cmtid
            if scroll == "1" { Navi.scrolltoComt = true }
            self.present(Navi, animated: false, completion: nil)
        }
        
    }
    
    @objc func userNotificationGetUnreviewedList(_ notification: Notification) {
        
        guard let ptid = notification.userInfo?["ptid"] as? String else { return }
       
        let vc = storyboard!.instantiateViewController(withIdentifier: "ApplierListTbV") as! ApplierListTbV
        vc.ptid = ptid
        vc.callGetUnreviewedListService()
        self.hideMainBar()
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    @objc func userNotificationGetAttendanceList(_ notification: Notification) {
        
        guard let ptid = notification.userInfo?["ptid"] as? String else { return }
      
        let vc = storyboard!.instantiateViewController(withIdentifier: "ParticipantsListTbV") as! ParticipantsListTbV
        vc.ptid = ptid
        vc.isHost = false
        vc.isExpired = "1"
        self.hideMainBar()
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
}

extension NotificationVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification_array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notify = notification_array[indexPath.row]
        
        cell.init_notification(serial_no: notify.serial_no, uid: notify.uid, img_url: notify.img_url, text: notify.text, time: notify.createtime, callapi: notify.callapi, isRead: notify.is_read, pid: notify.pid, ptid: notify.ptid, senduid: notify.senduid, cmtid: notify.cmtid, isPublic: notify.isPublic, username: notify.username, memo_img_url: notify.memo_img_url, width: self.view.frame.width)
        
        if notify.is_read == "0" {
            cell.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.1176470588, blue: 0.8352941176, alpha: 0.121682363)
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
