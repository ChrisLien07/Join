//
//  MyChatroomImgCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/21.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Agrume

class MyChatroomImgCell: UITableViewCell {

    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var img_pic: UIImageView!
    
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
        //設定時間
        let timeStamp = timestamp
        let timeInterval = TimeInterval(timeStamp)!/1000
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
            //
        dformatter.timeZone = TimeZone.current
        //
        img_pic.layer.cornerRadius = 211/15
        img_pic.contentMode = .scaleAspectFill
        img_pic.layer.masksToBounds = true
        img_pic.isUserInteractionEnabled = true
        DownloadImage(view: img_pic, img: msg, id: "",placeholder: .none)
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        img_pic.addGestureRecognizer(tap)
        //
        lbl_time.text = "\(dformatter.string(from: date))"
        lbl_time.font = .systemFont(ofSize: 11)
        lbl_time.textColor = .black
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let imageView = sender.view as! UIImageView
        let img = imageView.image
        if img != nil
        {
            let button = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
            button.tintColor = .black
            let agrume = Agrume(image: img!, background: .blurred(.regular), dismissal: .withButton(button))
            let vc = self.findViewController() as! ChatroomViewVC
            agrume.show(from: vc)
        }
    }
}
