//
//  LikeMeCVCell.swift
//  join
//
//  Created by ChrisLien on 2020/8/26.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class LikeMeCVCell: UICollectionViewCell {
    
    let img_user = UIImageView()
    let v_profile = UIView()
    let lbl_username = UILabel()
    let img_gender = UIImageView()
    let lbl_age = UILabel()
    let img_location = UIImageView()
    let img_constellation = UIImageView()
    let lbl_location = UILabel()
    let lbl_constellation = UILabel()
    let lbl_img_gender = UILabel()
    
    var img_urlArray: [String] = [String]()
    var uid = ""
    func init_like_profile(uid: String,
                           username: String,
                           gender_name: String,
                           age: String,
                           location_name: String,
                           constellation: String,
                           constellation_name: String,
                           img_urllist: String,
                           width:CGFloat,
                           height:CGFloat)
    {
        self.uid = uid
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(goProfile))
        img_user.isUserInteractionEnabled = true
        img_user.addGestureRecognizer(tap)
        //
        img_urlArray = img_urllist.components(separatedBy: ",")
        img_user.frame = CGRect(x: 0, y: 0, width: width, height: height)
        DownloadImage(view: img_user, img: img_urlArray[0], id: "uid:" + uid, placeholder: .none)
        img_user.contentMode = .scaleAspectFill
        img_user.layer.masksToBounds = true
        img_user.layer.cornerRadius = img_user.frame.height/12
        self.addSubview(img_user)
        //
        v_profile.frame = CGRect(x: 0, y: height - height/3.2 , width: width, height: height/3.2)
        v_profile.backgroundColor = .black
        v_profile.alpha = 0.7
        img_user.addSubview(v_profile)
        //
        lbl_username.frame = CGRect(x: 10, y: v_profile.frame.origin.y , width: 200, height: 100)
        lbl_username.text = username
        lbl_username.textColor = .white
        lbl_username.font = .systemFont(ofSize: 25)
        lbl_username.sizeToFit()
        img_user.addSubview(lbl_username)
        //
        lbl_img_gender.frame = CGRect(x: lbl_username.frame.origin.x + lbl_username.frame.width + 5, y: v_profile.frame.origin.y + 5, width: 20, height: 20)
        lbl_img_gender.font = .systemFont(ofSize: 14)
        lbl_img_gender.textColor = .white
        if gender_name == "男" {
            lbl_img_gender.text = "♀"
        }
        else if gender_name == "女" {
            lbl_img_gender.text = "♂"
        }
        img_user.addSubview(lbl_img_gender)
        //
        lbl_age.frame = CGRect(x: lbl_img_gender.frame.origin.x + lbl_img_gender.frame.width + 5, y: v_profile.frame.origin.y + 5 , width: 25, height: 20)
        lbl_age.text = age
        lbl_age.textColor = .white
        lbl_age.font = .systemFont(ofSize: 18)
        img_user.addSubview(lbl_age)
        //
        img_location.frame = CGRect(x: 10, y: lbl_username.frame.origin.y + lbl_username.frame.height + 2, width: 15, height: 15)
        img_location.image = UIImage(named: "baseline_place_black_24pt")
        img_location.tintColor = .white
        img_user.addSubview(img_location)
        //
        lbl_location.frame = CGRect(x: img_location.frame.origin.x  + img_location.frame.width + 5 , y: lbl_username.frame.origin.y + lbl_username.frame.height , width: 50, height: 20)
        lbl_location.text = location_name
        lbl_location.font = .systemFont(ofSize: 13)
        lbl_location.textColor = .white
        img_user.addSubview(lbl_location)
        //
        img_constellation.frame = CGRect(x: lbl_location.frame.origin.x + lbl_location.frame.width + 5 , y: lbl_username.frame.origin.y + lbl_username.frame.height , width: 20, height: 20)
        img_constellation.image = UIImage(named: "baseline_help_outline_black_48pt")
        img_constellation.tintColor = .white
        img_user.addSubview(img_constellation)
        img_constellation.isHidden = true
        //
        lbl_constellation.frame = CGRect(x: img_constellation.frame.origin.x  + img_constellation.frame.width + 5 , y: lbl_username.frame.origin.y + lbl_username.frame.height , width: 50, height: 20)
        lbl_constellation.text = constellation_name
        lbl_constellation.font = .systemFont(ofSize: 13)
        lbl_constellation.textColor = .white
        img_user.addSubview(lbl_constellation)
        if constellation_name == "不透露"
        {
            img_constellation.isHidden = true
            lbl_constellation.isHidden = true
        }
    }
    
    @objc func goProfile()
    {
        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UserProfileNavi") as! UserProfileNavi
        vc.uid = self.uid
        vc.isRen = true
        vc.isMatch = true
        self.findViewController()?.present(vc,animated: true)
    }
}
