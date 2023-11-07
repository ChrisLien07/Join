//
//  ChatroomViewVC.swift
//  join
//
//  Created by ChrisLien on 2020/9/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MJRefresh

class ChatroomViewVC: UIViewController {

    @IBOutlet weak var tbv_chatroom: UITableView!
    
    let dformatter = DateFormatter()
    
    var ref: DatabaseReference!
    var newMsgChild: DatabaseReference!
    
    var msg_array:[Msg] = []
    var msg_date_array:[Msg] = []
    var chtid = ""
    var friend_shortid = ""
    var username = ""
    var friend_uid = ""
    var img_url = ""

    let rc_foot = MJRefreshAutoFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        ref = Database.database().reference()
        newMsgChild = Database.database().reference().child("chatroom").child(chtid).childByAutoId()
        //
        rc_foot.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        tbv_chatroom.mj_footer = rc_foot
        //
        tbv_chatroom.delegate = self
        tbv_chatroom.dataSource = self
        tbv_chatroom.transform = CGAffineTransform(scaleX: 1, y: -1)
        //
        dformatter.timeZone = TimeZone.current
        dformatter.locale = NSLocale.current
        dformatter.dateFormat = "yyyy-MM-dd"
        //
        read_data_once()
    }
    
    func isSameDay(_ date1:Date, _ date2:Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func sortDate()
    {
        var tmpTS = 0
        //老到新
        self.msg_date_array = self.msg_date_array.sorted{ $0.timestamp < $1.timestamp}
        for i in self.msg_date_array
        {
            if tmpTS == 0
            {
                tmpTS = Int(i.timestamp)!
                let timeStamp = i.timestamp
                let timeInterval = TimeInterval(timeStamp)!/1000
                let date = Date(timeIntervalSince1970: timeInterval)
                //
                let tmpMsg = Msg()
                tmpMsg.msg = dformatter.string(from: date)
                tmpMsg.timestamp = String(tmpTS - 1)
                tmpMsg.isDateChanged = true
                msg_date_array.append(tmpMsg)
            }
            else
            {
                let timeInterval2 = TimeInterval(tmpTS)/1000
                let lastDate = Date(timeIntervalSince1970: timeInterval2)
                
                let timeStamp = i.timestamp
                let timeInterval = TimeInterval(timeStamp)!/1000
                let date = Date(timeIntervalSince1970: timeInterval)
                
                if !isSameDay(date, lastDate)
                {
                    let tmpMsg = Msg()
                    tmpMsg.msg = dformatter.string(from: date)
                    tmpMsg.timestamp = String(tmpTS + 1)
                    tmpMsg.isDateChanged = true
                    msg_date_array.append(tmpMsg)
                }
                tmpTS = Int(i.timestamp)!
            }
        }
    }

    func read_data_once()
    {
        ref.child("chatroom").child(self.chtid).queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
            if let msgs = snapshot.value as? [String: Any]
            {
                for message in msgs
                {
                    if let msg = message.value as? [String : Any]
                    {
                        let tmpMsg = Msg()
                        parseMsg(message: tmpMsg, msg: msg)
                        if msg.keys.contains("isread") {
                            tmpMsg.isRead = msg["isread"] as! [String]
                        } else if msg.keys.contains("isRead") {
                            tmpMsg.isRead = msg["isRead"] as! [String]
                        }
                        self.msg_array.append(tmpMsg)
                        if !tmpMsg.isRead.contains(globalData.shortid)
                        {
                            self.ref.child("chatroom/\(self.chtid)/\(message.key)/isread").setValue([self.friend_shortid,globalData.shortid])
                        }
                    } 
                }
                self.msg_date_array = self.msg_array
                self.sortDate()
                self.msg_date_array = self.msg_date_array.sorted{ $0.timestamp > $1.timestamp}
                self.tbv_chatroom.reloadData()
                self.listen_type_add()
            }
            else
            {
                self.listen_type_add()
            }
        }) { (error) in
           
        }
    }
    
    func listen_type_add() {
        ref.child("chatroom").child(self.chtid).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) -> Void in
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
                if !self.msg_array.contains(where: { $0.timestamp == tmpMsg.timestamp}) {
                    self.msg_array.append(tmpMsg)
                    self.checkUnwantedWord(message: tmpMsg)
                    self.msg_date_array = self.msg_array
                    self.sortDate()
                    self.msg_date_array = self.msg_date_array.sorted{ $0.timestamp > $1.timestamp}
                    self.tbv_chatroom.reloadData()
                }
            }
        })
    }
    
    func checkUnwantedWord(message: Msg) {
        for i in globalData.unwantedWordArray {
            if message.msg.contains(i), !message.isRead.contains(globalData.shortid) {
                let tmpMsg = Msg()
                tmpMsg.msg = "提醒您~防人之心不可無，若對方沒聊多久和您要私下聯繫方式，請多多留意~~"
                tmpMsg.timestamp = String(Int(message.timestamp)! + 1)
                tmpMsg.isDateChanged = true
                self.msg_array.append(tmpMsg)
            }
        }
    }
    
    
    // MARK: - @objc
    @objc func loadmore()
    {
        if self.msg_array.count > 0
        {
            let queryEndingTime = msg_array[self.msg_array.count - 1].timestamp
            ref.child("chatroom").child(self.chtid).queryOrdered(byChild: "time").queryEnding(atValue: Int(queryEndingTime)).queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let msgs = snapshot.value as? [String: Any]
                {
                    for message in msgs
                    {
                        if let msg = message.value as? [String : Any]
                        {
                            let tmpMsg = Msg()
                            parseMsg(message: tmpMsg, msg: msg)
                            if msg.keys.contains("isread")
                            {
                                tmpMsg.isRead = msg["isread"] as! [String]
                            }
                            else if msg.keys.contains("isRead")
                            {
                                tmpMsg.isRead = msg["isRead"] as! [String]
                            }
                            if !tmpMsg.isRead.contains(globalData.shortid) {
                                self.ref.child("chatroom/\(self.chtid)/\(message.key)/isread").setValue([self.friend_shortid,globalData.shortid])
                            }
                            
                            if !self.msg_array.contains(where: { $0.timestamp == tmpMsg.timestamp}) {
                                self.msg_array.append(tmpMsg)
                            }
                        }
                    }
                    self.msg_date_array = self.msg_array
                    self.sortDate()
                    self.msg_date_array = self.msg_date_array.sorted{ $0.timestamp > $1.timestamp}
                    self.tbv_chatroom.reloadData()
                    self.tbv_chatroom.mj_footer!.endRefreshing()
                }
            }) { (error) in
            }
        }
    }
}

extension ChatroomViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msg_date_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = msg_date_array[indexPath.row]
        if msg.isDateChanged
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "date_cell", for: indexPath) as! ChatroomDateCell
            cell.selectionStyle = .none
            cell.init_date(msg: msg.msg)
            return cell
        }
        
        if msg.id == globalData.shortid
        {
            if msg.type == "img"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "my_CTR_img_cell", for: indexPath) as! MyChatroomImgCell
                cell.selectionStyle = .none
                cell.init_tbv(username: username, msg: msg.msg, shortid: friend_shortid, friend_uid: friend_uid, timestamp: msg.timestamp,width: self.view.frame.width)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyChatroomCell", for: indexPath) as! MyChatroomCell
                cell.selectionStyle = .none
                cell.init_tbv(username: username, msg: msg.msg, shortid: friend_shortid, friend_uid: friend_uid, timestamp: msg.timestamp,width: self.view.frame.width)
                return cell
            }
        }
        else
        {
            if msg.type == "img"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "fri_CTR_img_cell", for: indexPath) as! FriendChatroomImgCell
                cell.selectionStyle = .none
                cell.init_tbv(username: username, img_url: img_url, msg: msg.msg, shortid: friend_shortid, friend_uid: friend_uid, timestamp: msg.timestamp,width: self.view.frame.width)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendChatroomCell", for: indexPath) as! FriendChatroomCell
                cell.selectionStyle = .none
                cell.init_tbv(username: username, img_url: img_url, msg: msg.msg, shortid: friend_shortid, friend_uid: friend_uid, timestamp: msg.timestamp,width: self.view.frame.width)
                return cell
            }
        }
    }
}
