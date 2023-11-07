//
//  SettingCell.swift
//  join
//
//  Created by 連亮涵 on 2020/7/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    let lbl_title = UILabel()
    let img_title = UIImageView()
    
    func initSetting(title: String,img:String)
    {

        //設定圖片
        img_title.frame = CGRect(x:16,y:18,width: 25,height: 25)
        img_title.image = UIImage(named: img)
        self.addSubview(img_title)
        //
        if title == "查看誰喜歡我"
        {
            img_title.frame = CGRect(x:18,y:20,width: 22,height: 20)
            img_title.tintColor = .red
        }
        else if title == "我的VIP"
        {
            img_title.frame = CGRect(x:19,y:20,width: 22,height: 18)
        }
        else if title == "封鎖名單"
        {
            img_title.tintColor = .black
        }
        else
        {
            img_title.tintColor = .black
        }
        lbl_title.frame = CGRect(x: img_title.frame.origin.x + img_title.frame.width + 20  ,y: 15,width:  200,height: 30)
        lbl_title.text = title
        lbl_title.textColor = UIColor.black.withAlphaComponent(0.75)
        lbl_title.textAlignment = .natural
        self.addSubview(lbl_title)
    }

}


        
        
       
