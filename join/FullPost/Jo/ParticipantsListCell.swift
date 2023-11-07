//
//  ParticipantsListCell.swift
//  join
//
//  Created by ChrisLien on 2020/11/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ParticipantsListCell: UITableViewCell {
    
    let user_img: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let lbl_username: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    let lbl_info: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = Colors.rgb112Gray
        return lbl
    }()
    
    let lbl_time: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = Colors.rgb112Gray
        return lbl
    }()
    
    let v_main = UIView()
    
    var uid: String = ""

    func initAttList(uid: String,
                     username:String,
                     img_url:String,
                     age: String,
                     timespan:String,
                     location_Name: String,
                     height: CGFloat,
                     width: CGFloat,
                     isEdited: Bool,
                     isExpired: String,
                     isHost: String,
                     isMyself: String)
    {
        self.uid = uid
        
        if isEdited && isMyself != "1" {
            v_main.frame = CGRect(x: 40, y: 0, width: width, height: height)
            //user_img.frame = CGRect(x:55,y:14,width: 40, height: 40)
        } else {
            //user_img.frame = CGRect(x:15,y:14,width: 40, height: 40)
            v_main.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        
        addSubview(v_main)
        [user_img, lbl_username, lbl_info, lbl_time].forEach{ v_main.addSubview($0) }
        
        //setValues
        DownloadImage(view: user_img, img: img_url, id: "uid:" + uid,placeholder: UIImage(named: "user.png"))
        lbl_username.text = username
        lbl_info.text = "\(location_Name) \(age)歲"
        lbl_time.text = "\(timespan)"
        
        setupAnchors()
        
        let iconTap = UITapGestureRecognizer.init(target: self, action: #selector(showUser))
        user_img.addGestureRecognizer(iconTap)
    }
    
    func setupAnchors() {
        user_img.anchor(top: v_main.topAnchor, leading: v_main.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 10, left: 15, bottom: 0, right: 0), size: CGSize(width: 40, height: 40))
        lbl_username.anchor(top: v_main.topAnchor, leading: v_main.leadingAnchor, bottom: v_main.bottomAnchor, trailing: nil, padding: .init(top: 20, left: 67, bottom: 20, right: 0))
        lbl_username.trailingAnchor.constraint(lessThanOrEqualTo: v_main.trailingAnchor, constant: 140).isActive = true
        lbl_info.anchor(top: v_main.topAnchor, leading: lbl_username.trailingAnchor, bottom: v_main.bottomAnchor, trailing: nil, padding: .init(top: 20, left: 7, bottom: 20, right: 0), size: CGSize(width: 95, height: 0))
        lbl_time.anchor(top: v_main.topAnchor, leading: nil, bottom: v_main.bottomAnchor, trailing: v_main.trailingAnchor, padding: .init(top: 21, left: 0, bottom: 21, right: 15), size: CGSize(width: 50, height: 0))
      
    }
    
    @objc func showUser() {
        let vc = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = uid
        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}


