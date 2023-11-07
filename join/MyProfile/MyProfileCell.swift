//
//  NewDownProfileCell.swift
//  join
//
//  Created by ChrisLien on 2020/10/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MyProfileCell: UITableViewCell {

    let lbl_title = UILabel()
    let lbl_txt = UILabel()
    
    func init_profile(title:String,
                      user_info:String,
                      job_name:String,
                      bloodtype:String,
                      personality_name:String,
                      width:CGFloat)
    {
        
        lbl_title.frame = CGRect(x: 15, y: 12, width: 50, height: 20)
        lbl_title.text = title
        lbl_title.textColor = Colors.rgb149Gray
        lbl_title.font = .systemFont(ofSize: 15)
        self.addSubview(lbl_title)
        lbl_txt.frame = CGRect(x: width - 200, y: 12, width: 180, height: 20)
        lbl_txt.font = .systemFont(ofSize: 15)
        lbl_txt.textAlignment = .right
        lbl_txt.numberOfLines = 6
        self.addSubview(lbl_txt)
        switch title {
        case "關於我":
            lbl_txt.frame = CGRect(x: 15, y: 35, width: width - 30, height: 100)
           
            lbl_txt.textAlignment = .left
            lbl_txt.text = user_info
            if user_info == "" {
                lbl_txt.text = "嗨嗨，你好"
                lbl_txt.textColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
            }
            lbl_txt.sizeToFit()
            lbl_txt.frame.origin.y = 40
        case "":
            lbl_title.frame = .zero
            lbl_txt.frame = CGRect(x: 15, y: 10, width: width - 30, height: 100)
            lbl_txt.text = user_info
            lbl_txt.textAlignment = .left
            if user_info == "" {
                lbl_txt.text = "嗨嗨，你好"
                lbl_txt.textColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
            }
            lbl_txt.sizeToFit()
            lbl_txt.frame.origin.y = 10
        case "血型":
            if bloodtype == "000" {
                lbl_txt.text = "不透露"
            } else {
                lbl_txt.text = bloodtype
            }
        case "職業":
            lbl_txt.text = job_name
        case "個性":
            lbl_txt.frame = CGRect(x: width - 220, y: 12, width: 200, height: 44)
            lbl_txt.text = personality_name
        default:
            break
        }
    }
}
