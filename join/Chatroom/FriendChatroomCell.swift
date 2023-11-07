//
//  ChatroomCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/17.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class FriendChatroomCell: UITableViewCell {
    
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var txt_msg: UITextView!
    @IBOutlet weak var img_userIcon: UIImageView!
    
    var msgHeight : CGFloat = 0
    var friend_uid = ""
    
    func init_tbv(username: String,
                  img_url: String,
                  msg: String,
                  shortid: String,
                  friend_uid: String,
                  timestamp: String,
                  width: CGFloat)
    {
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.friend_uid = friend_uid
        //設定頭像
        img_userIcon.configureUserIcon(target: self, cornerRadious: img_userIcon.frame.width/2, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: img_url, id: "uid:" + friend_uid, placeholder: UIImage(named: "user.png"))
        //設定文字
        txt_msg.text = msg
        txt_msg.textAlignment = .left
        txt_msg.layer.cornerRadius = 10
        txt_msg.layer.borderWidth = 1
        txt_msg.layer.borderColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        txt_msg.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1)
        txt_msg.backgroundColor = .white
        txt_msg.isEditable = false
        //設定時間
        let timeStamp = timestamp
        let timeInterval = TimeInterval(timeStamp)!/1000
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone.current
        dformatter.locale = NSLocale.current
        dformatter.dateFormat = "HH:mm"
        //
        lbl_time.text = "\(dformatter.string(from: date))"
        lbl_time.font = .systemFont(ofSize: 11)
        lbl_time.textColor = .black
    }
    
    @objc func showUser()
    {
        let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = self.friend_uid
        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
