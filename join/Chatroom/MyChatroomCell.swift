//
//  MyChatroomCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/17.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MyChatroomCell: UITableViewCell {

    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var txt_msg: UITextView!
    
    var msgHeight : CGFloat = 0
    var friend_uid = ""
    
    func init_tbv(username: String,
                  msg: String,
                  shortid: String,
                  friend_uid: String,
                  timestamp: String,
                  width: CGFloat)
    {
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
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
        dformatter.dateFormat = "HH:mm"
            //
        dformatter.timeZone = TimeZone.current
            //
        lbl_time.text = "\(dformatter.string(from: date))"
        lbl_time.font = .systemFont(ofSize: 11)
        lbl_time.textColor = .black
    }
}
