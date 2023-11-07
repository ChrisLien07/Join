//
//  MainChatCVCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MainChatCVCell: UICollectionViewCell {
    
    let img_userIcon = UIImageView()
    let lbl_username: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    let img_new = UIImageView()
    
    var chtid = ""
    var shortid = ""
    var username = ""
    var friend_uid = ""
    var img_url = ""
    
    var ref: DatabaseReference!
    
    func init_cell(username: String,
                  chtid: String,
                  friend_uid: String,
                  img_url: String,
                  shortid: String,
                  isStop: String,
                  isnewmsg: String,
                  width: CGFloat)
    {
        self.chtid = chtid
        self.shortid = shortid
        self.username = username
        self.friend_uid = friend_uid
        self.img_url = img_url
        //
        ref = Database.database().reference()
        setup_img_userIcon()
        setup_lbl_username()
    }
    
    func setup_img_userIcon() {
        img_userIcon.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        img_userIcon.configureUserIcon(target: self, cornerRadious: 27.5, selector: #selector(tapped))
        DownloadImage(view: img_userIcon, img: img_url, id: "uid:" + friend_uid, placeholder: .none)
        self.addSubview(img_userIcon)
    }
    
    func setup_lbl_username() {
        lbl_username.frame = CGRect(x: 0, y: 55, width: 55, height: 15)
        lbl_username.text = username
        self.addSubview(lbl_username)
    }
    
    func callOpenChatService() {
        let request = createHttpRequest(Url: globalData.OpenChatUrl , HttpType: "POST", Data: "token=\(globalData.token)&frienduid=\(friend_uid)")
        let task = URLSession.shared.dataTask(with: request)  { data, response, error in
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
    
    func check()
    {
        let userID = Auth.auth().currentUser?.uid
        var CID_array: [String] = [String]()
        ref.child("chatroom_user").child(userID!).child("CID").observeSingleEvent(of: .value, with: { (snapshot) in
            if let CIDS = snapshot.value as? [String]
            {
                for CID in CIDS {
                    CID_array.append(CID)
                }
                if !CID_array.contains(self.chtid) {
                    CID_array.append(self.chtid)
                    self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
                    self.callOpenChatService()
                }
            }
            else
            {
                CID_array.append(self.chtid)
                self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
                self.callOpenChatService()
            }
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "ChatroomVC") as! ChatroomVC
            vc.chtid = self.chtid
            vc.username = self.username
            vc.img_url = self.img_url
            vc.friend_uid = self.friend_uid
            vc.friend_shortid = self.shortid
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        }) { (error) in
            print("0")
        }
    }
    
    @objc func tapped() {
        check()
    }
}

