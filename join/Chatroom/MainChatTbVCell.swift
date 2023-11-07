//
//  MainChatCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MainChatTbVCell: UITableViewCell {

    let lbl_username = UILabel()
    let lbl_msg = UILabel()
    let img_userIcon = UIImageView()
    
    let img_new: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "baseline_fiber_manual_record_black_24pt")
        iv.layer.cornerRadius = 7.5
        iv.tintColor = .red
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var chtid = ""
    var shortid = ""
    var username = ""
    var friend_uid = ""
    var lasted_msg = ""
    var img_url = ""
    var hasFirstMsg = false
    var ref: DatabaseReference!
    
    func init_tbv(data: Chat,
                  isfirst: String,
                  width: CGFloat)
    {
        self.img_url = data.img_url
        self.friend_uid = data.friend_uid
        self.username = data.username
        self.shortid = data.shortid
        self.lasted_msg = data.lasted_msg
        self.chtid = data.chtid
        self.hasFirstMsg = data.hasFirstMsg
        ref = Database.database().reference()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        //
        if isfirst == "Y" {
            img_userIcon.frame = CGRect(x: 15, y: 27, width: 55, height: 55)
            img_new.frame = CGRect(x: 70 - 15, y: 82 - 15 - 2, width: 15, height: 15)
            lbl_username.frame = CGRect(x: 80, y: 35, width: 150, height: 21)
            lbl_msg.frame = CGRect(x: 80, y: 58, width: width - 80 - 15, height: 18)
        } else {
            img_userIcon.frame = CGRect(x: 15, y: 12.5, width: 55, height: 55)
            img_new.frame = CGRect(x: 70 - 15, y: 67.5 - 15 - 2, width: 15, height: 15)
            lbl_username.frame = CGRect(x: 80, y: 20.5, width: 150, height: 21)
            lbl_msg.frame = CGRect(x: 80, y: 43.5, width: width - 80 - 15, height: 18)
        }
        if  data.isnewmsg == "1" {
            img_new.isHidden = false
        } else {
            img_new.isHidden = true
        }

        [lbl_username,img_userIcon,img_new,lbl_msg].forEach { self.addSubview($0) }
        setupSubViews()
    }
    
    func setupSubViews() {
        img_userIcon.configureUserIcon(target: self, cornerRadious: 27.5, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: img_url, id: "uid:" + friend_uid, placeholder: .none)
        lbl_msg.textColor = Colors.rgb149Gray
        lbl_msg.text = lasted_msg
        lbl_username.text = username
    }
    
    func check() {
        let userID = Auth.auth().currentUser?.uid
        var CID_array: [String] = [String]()
        ref.child("chatroom_user").child(userID!).child("CID").observeSingleEvent(of: .value, with: { (snapshot) in
            if let CIDS = snapshot.value as? [String] {
                for CID in CIDS {
                    CID_array.append(CID)
                }
                if !CID_array.contains(self.chtid) {
                    CID_array.append(self.chtid)
                    self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
                }
            } else {
                CID_array.append(self.chtid)
                self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
            }
        }) { (error) in
            print("0")
        }
        //
        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ChatroomVC") as! ChatroomVC
        vc.chtid = self.chtid
        vc.username = self.username
        vc.img_url = self.img_url
        vc.friend_uid = self.friend_uid
        vc.friend_shortid = self.shortid
        vc.hasFirstMsg = self.hasFirstMsg
        findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func tapped() {
        check()
    }
    
    @objc func showUser()
    {
        let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = self.friend_uid
        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
