//
//  MainChatVC.swift
//  join
//
//  Created by ChrisLien on 2020/9/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainChatVC: UIViewController, UISearchBarDelegate {
   
    @IBOutlet weak var v_newfriend: UIView!
    @IBOutlet weak var tbv_chatrooms: UITableView!
    @IBOutlet weak var cv_upChatrooms: UICollectionView!
    @IBOutlet var searchbar: UISearchBar!
    
    var ref: DatabaseReference!
    
    var chatroom_open_array: [Chat] = []
    var chatroom_close_array: [Chat] = []
    var filterData:[Chat] = []
    var originData:[Chat] = []
    
    var new = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchbarEndEdit))
        self.view.addGestureRecognizer(tap)
        //
        ref = Database.database().reference()
        v_newfriend.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 183))
        tbv_chatrooms.anchor(top: v_newfriend.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        //
        tbv_chatrooms.dataSource = self
        tbv_chatrooms.delegate = self
        cv_upChatrooms.delegate = self
        cv_upChatrooms.dataSource = self
        //
        searchbar.delegate = self
        searchbar.placeholder = "搜尋對象名字"
        navigationItem.titleView = searchbar
        creatObserver()
        collectionViewLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbv_chatrooms.layer.cornerRadius = tbv_chatrooms.frame.height/16
        showMainBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.items![1].badgeValue = nil
        callFriendListService()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.endEdit()
        super.viewWillDisappear(animated)
    }
    
    func creatObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(userNotificationOpenChat), name: userNotifications.openChat, object: nil)
    }
    
    func listen_type_add() {
        var numberofUnread = 0
        for chatroom in chatroom_open_array {
            ref.child("chatroom").child(chatroom.chtid).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) -> Void in
                if let value = snapshot.value as? [String: Any]
                {
                    let tmpMsg = Msg()
                    parseMsg(message: tmpMsg, msg: value)
                    
                    if value.keys.contains("isread") {
                        tmpMsg.isRead = value["isread"] as! [String]
                    } else if value.keys.contains("isRead") {
                        tmpMsg.isRead = value["isRead"] as! [String]
                    }
                    
                    if !tmpMsg.isRead.contains(globalData.shortid) {
                        chatroom.isnewmsg = "1"
                        numberofUnread += 1
                        UIApplication.shared.applicationIconBadgeNumber = numberofUnread
                        self.tabBarController?.tabBar.items![1].badgeValue = ""
                    } else {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                    
                    chatroom.timestamp = tmpMsg.timestamp
                    chatroom.hasFirstMsg = true
                    
                    if tmpMsg.type == "img" {
                        chatroom.lasted_msg = "照片已傳送"
                    } else {
                        chatroom.lasted_msg = value["msg"] as? String ?? ""
                    }
                    
                    self.chatroom_open_array = self.chatroom_open_array.sorted{ $0.timestamp > $1.timestamp}
                    self.tbv_chatrooms.reloadData()
                    
                }
            })
        }
        self.tbv_chatrooms.reloadData()
        originData = chatroom_open_array
    }
    
    func callFriendListService() {
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
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        self.chatroom_open_array.removeAll()
                        self.chatroom_close_array.removeAll()
                        for chat in responseJSON["list"] as! [[String: Any]] {
                            let tmpChat = Chat()
                            parseChat(chat: tmpChat, cha: chat)
                            //
                            let dateformat = DateFormatter()
                            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            dateformat.locale = Locale(identifier: "zh_CN")
                            let tmpcreattime = dateformat.date(from: tmpChat.modifiedtime)!
                            tmpChat.timestamp = String(tmpcreattime.timeIntervalSince1970*1000)
                            //
                            if tmpChat.ischatopen == "0" {
                                self.chatroom_close_array.append(tmpChat)
                            } else if tmpChat.ischatopen == "1" {
                                self.chatroom_open_array.append(tmpChat)
                            }
                        }
                        self.listen_type_add()
                        self.cv_upChatrooms.reloadData()
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        DispatchQueue.main.async {
                            shortInfoMsg(msg: "聊天室尚無訊息哦!快去想認識交朋友吧~~", vc: self,sec: 2)
                            self.chatroom_open_array.removeAll()
                            self.chatroom_close_array.removeAll()
                            self.tbv_chatrooms.reloadData()
                            self.cv_upChatrooms.reloadData()
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
    
    @objc func refresh() {
        callFriendListService()
    }
    
    @objc func searchbarEndEdit() {
        searchbar.endEditing(true)
    }
    
    @objc func userNotificationOpenChat(_ notification: Notification) {
        guard let chtid = notification.userInfo?["chtid"] as? String else { return }
        let senduid = notification.userInfo?["senduid"] as? String ?? ""
        let username = notification.userInfo?["username"] as? String ?? ""
        let userIcon = notification.userInfo?["userIcon"] as? String ?? ""
        let shortid = notification.userInfo?["shortid"] as? String ?? ""
       
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatroomVC") as! ChatroomVC
        vc.chtid = chtid
        vc.friend_uid = senduid
        vc.username = username
        vc.img_url = userIcon
        vc.friend_shortid = shortid
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func collectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 15, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 55, height: 55 + 15)
        cv_upChatrooms.collectionViewLayout = flowLayout
    }
    
    //MARK: - SearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            chatroom_open_array = chatroom_open_array.filter({$0.username.range(of: searchText) != nil})
        } else {
            chatroom_open_array = originData.sorted{ $0.timestamp > $1.timestamp}
        }
        tbv_chatrooms.reloadData()
    }
}

extension MainChatVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatroom_open_array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainChatTbVCell", for: indexPath) as! MainChatTbVCell
        let chat = chatroom_open_array[indexPath.row]
        var isfirst = "N"
        if indexPath.row == 0 {
            isfirst = "Y"
        }
        cell.init_tbv(data: chat, isfirst: isfirst, width: view.frame.width)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 96
        }
        return 82
    }
}

extension MainChatVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatroom_close_array.count
    }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "MainChatCVCell", for: indexPath) as! MainChatCVCell
        let chatArray = chatroom_close_array[indexPath.item]
        cell.init_cell(username: chatArray.username, chtid: chatArray.chtid, friend_uid: chatArray.friend_uid, img_url: chatArray.img_url, shortid: chatArray.shortid, isStop: chatArray.isStop, isnewmsg: chatArray.isnewmsg,width: self.view.frame.width)
        return cell
    }
}
