//
//  MainTabBar.swift
//  join
//
//  Created by 連亮涵 on 2020/5/29.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainTabBar: UITabBarController,UITabBarControllerDelegate {

    var chatroom_array: [String] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(selectIndex0(_:)), name: NSNotification.Name(rawValue: "selectHome"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectChat(_:)), name: NSNotification.Name(rawValue: "selectChat"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectNoty(_:)), name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callGetNotifyCountService), name: NSNotification.Name(rawValue: "redDot"), object: nil)
        //
        delegate = self
        tabBar.tintColor = Colors.themePurple
        queryUser()
        callGetNotifyCountService()
        callGetPhoneService()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if  getTPETime(format: "yyyyMMdd") != UserDefaults.standard.string(forKey: "TodayInfo") {
            showANNPage()
        }
    }
    
    @objc func callGetNotifyCountService(){ //取得通知數
        let request = createHttpRequest(Url: globalData.GetNotifyCountUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let notifyCount = responseJSON["notifyCount"] as? String
                        {
                            if notifyCount != "0" {
                                self.tabBar.items![2].badgeValue = ""
                            } else {
                                self.tabBar.items![2].badgeValue = nil
                            }
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

    func callGetPhoneService() { //取得手機號
        let request = createHttpRequest(Url: globalData.GetPhoneUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
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
                            globalData.phonenum = responseJSON["phonenum"] as! String
                            self.callFolderNameService()
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
    
    func callFolderNameService() { //firebase圖片資料夾名稱
        let newPhoneNum = globalData.phonenum.replacingOccurrences(of: "+", with: "%2B")
        let request = createHttpRequest(Url: globalData.GetFolderNameUrl, HttpType: "POST", Data: "&phonenum=\(newPhoneNum)")
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
                        let folder = responseJSON["foldername"] as! String
                        globalData.folderName = folder
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.present(vc, animated: true, completion: nil)
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
    
    func callFriendListService() { //聊天室數量
        let request = createHttpRequest(Url: globalData.QueryFriendListUrl, HttpType: "POST", Data: "token=\(globalData.token)")
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
                        self.chatroom_array.removeAll()
                        for chat in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpChat = Chat()
                            tmpChat.chtid = chat["chtid"] as! String
                            tmpChat.ischatopen = chat["ischatopen"] as! String
                            if tmpChat.ischatopen == "1" {
                                self.chatroom_array.append(tmpChat.chtid)
                            }
                        }
                        self.listen_type_add()
                    }
                }
                else if responseJSON["code"] as! Int == 127
                {
                    
                }
                else
                {
                    DispatchQueue.main.async {
                        //ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func listen_type_add() { //監聽新訊息 
        var numberofUnread = 0
        for i in chatroom_array {
            ref.child("chatroom").child(i).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) -> Void in
                if let value = snapshot.value as? [String: Any]
                {
                    // Get user value
                    let tmpMsg = Msg()
                    parseMsg(message: tmpMsg, msg: value)
                    if value.keys.contains("isread") {
                        tmpMsg.isRead = value["isread"] as! [String]
                    } else if value.keys.contains("isRead") {
                        tmpMsg.isRead = value["isRead"] as! [String]
                    }
                    if !tmpMsg.isRead.contains(globalData.shortid) {
                        self.tabBar.items![1].badgeValue = ""
                        numberofUnread += 1
                        UIApplication.shared.applicationIconBadgeNumber = numberofUnread
                    }
                }
            })
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBar.tintColor =  Colors.themePurple
        callGetNotifyCountService()
    }
    
    func showANNPage() {
        NetworkManager.shared.callGetAnnouncementListService { (code, title, content, msg) in
            switch code {
            case 0:
                if content != nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                    vc.annTitle = title!
                    vc.annContent = content!
                    self.present(vc, animated: true, completion: nil)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                print("empty")
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
            }
        }
    }
    
    func queryUser() {
        NetworkManager.shared.callQueryUserService {
            self.callFriendListService()
        }
    }
    
    @objc func selectIndex0(_ notification: NSNotification) {
        if selectedIndex != 0 {
            self.selectedIndex = 0
        }
    }
    
    @objc func selectChat(_ notification: NSNotification) {
        if selectedIndex != 1 {
            self.selectedIndex = 1
        }
    }
    
    @objc func selectNoty(_ notification: NSNotification) {
        if selectedIndex != 2 {
            self.selectedIndex = 2
        }
    }
}
