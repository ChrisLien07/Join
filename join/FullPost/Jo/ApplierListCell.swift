//
//  atttendListCell.swift
//  join
//
//  Created by 連亮涵 on 2020/7/6.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ApplierListCell: UITableViewCell {
    
    let v_Main = UIView()
    let user_img = UIImageView()
    let lbl_username = UILabel()
    let lbl_Info = UILabel()
    let lbl_Time = UILabel()
    
    var uid: String = ""
    
    func initAttList(uid: String,
                     username:String,
                     img_url:String,
                     age: String,
                     timespan:String,
                     location_Name: String,
                     height: CGFloat,
                     width: CGFloat,
                     isEdited: Bool)
    {
        self.uid = uid
        v_Main.frame = CGRect(x:0,y:0,width: width,height: height)
        self.addSubview(v_Main)
        //
        if isEdited {
            user_img.frame = CGRect(x:50,y:5,width: height - 10 ,height: height - 10 )
        } else {
            user_img.frame = CGRect(x:10,y:5,width: height - 10 ,height: height - 10 )
        }
        //設置圖片
        user_img.contentMode = .scaleAspectFill
        user_img.clipsToBounds = true
        user_img.layer.cornerRadius = user_img.frame.height / 2
        user_img.isUserInteractionEnabled = true
        DownloadImage(view: user_img, img: img_url, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        let iconTap = UITapGestureRecognizer.init(target: self, action: #selector(showUser))
        user_img.addGestureRecognizer(iconTap)
        v_Main.addSubview(user_img)
        //設定文字
        lbl_username.frame = CGRect(x: user_img.frame.origin.x  + user_img.frame.width + 10 ,y: 0 , width: 100 ,height: 20)
        lbl_username.text = username
        lbl_username.font = .systemFont(ofSize: 18)
        lbl_username.sizeToFit()
        lbl_username.center.y = v_Main.center.y
        lbl_username.textColor = UIColor.black
        v_Main.addSubview(lbl_username)
        //
        lbl_Info.frame = CGRect(x: lbl_username.frame.origin.x + lbl_username.frame.width + 20 , y: 0, width: 100, height: 20)
        lbl_Info.text = "\(location_Name),\(age)歲"
        lbl_Info.font = .systemFont(ofSize: 14)
        lbl_Info.sizeToFit()
        lbl_Info.center.y = v_Main.center.y
        lbl_Info.textColor = UIColor.black
        v_Main.addSubview(lbl_Info)
        //
        lbl_Time.frame = CGRect(x: lbl_Info.frame.origin.x + lbl_Info.frame.width + 30 , y: 0 , width: 100, height: 20)
        lbl_Time.text = "\(timespan)"
        lbl_Time.font = .systemFont(ofSize: 12)
        lbl_Time.sizeToFit()
        lbl_Time.center.y = v_Main.center.y
        lbl_Time.textColor = UIColor.black
        v_Main.addSubview(lbl_Time)
    }
    
    @objc func showUser()
    {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC
        {
            userInfoVC.uid = uid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }

}

