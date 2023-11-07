//
//  ParticipantsRatingCell.swift
//  join
//
//  Created by ChrisLien on 2020/11/27.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Cosmos

class ParticipantsRatingCell: UITableViewCell {

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
        
    let v_stars: CosmosView = {
        let v = CosmosView()
        v.settings.filledImage = ratingStar.fillBlue_16pt
        v.settings.emptyImage = ratingStar.emptyBlue_16pt
        v.settings.fillMode = .half
        v.settings.starSize = 16
        return v
    }()
        
    var uid: String = ""
        
    override func prepareForReuse() {
        v_stars.prepareForReuse()
    }
        
    func initAttList(uid: String,
                     username:String,
                     img_url:String,
                     age: String,
                     timespan:String,
                     location_Name: String,
                     height: CGFloat,
                     width: CGFloat,
                     isEdited: Bool,
                     starRating: String,
                     isExpired: String,
                     isHost: String,
                     isMyself: String)
    {
        self.uid = uid
        //設置圖片
        DownloadImage(view: user_img, img: img_url, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        let iconTap = UITapGestureRecognizer.init(target: self, action: #selector(showUser))
        user_img.addGestureRecognizer(iconTap)
        //設定文字
        lbl_username.text = username
        lbl_info.text = "\(location_Name) \(age)歲"
        lbl_time.text = "\(timespan)"
        v_stars.rating = Double(starRating)!
        //
        [user_img, lbl_username, lbl_info, lbl_time,v_stars].forEach{ self.addSubview($0) }
        setupRatingAnchors()
    }
    
    func setupRatingAnchors() {
        user_img.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 14, left: 15, bottom: 0, right: 0), size: CGSize(width: 40, height: 40))
        lbl_username.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil, padding: .init(top: 15, left: 67, bottom: 31, right: 0))
        lbl_username.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: 140).isActive = true
        lbl_info.anchor(top: self.topAnchor, leading: lbl_username.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 15, left: 7, bottom: 0, right: 0), size: CGSize(width: 95, height: 22))
        lbl_time.anchor(top: self.topAnchor, leading: nil, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 10), size: CGSize(width: 50, height: 20))
        v_stars.anchor(top: lbl_username.bottomAnchor, leading: user_img.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0), size: CGSize(width: 100, height: 20))
    }
    
    @objc func showUser()
    {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            userInfoVC.uid = uid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
}

