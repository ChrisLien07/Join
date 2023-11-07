//
//  RatingCell.swift
//  join
//
//  Created by ChrisLien on 2020/11/20.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Cosmos

class RatingCell: UITableViewCell {

    let img_userIcon = UIImageView()
    let lbl_username = UILabel()
    
    let lbl_time: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.font = UIFont(name: "Helvetica-Bold", size: 14)
        lbl.textColor = Colors.rgb91Gray
        return lbl
    }()
    
    let txt_comment: UITextView = {
        let txt = UITextView()
        txt.textAlignment = .left
        txt.layer.cornerRadius = 10
        txt.textColor = Colors.rgb91Gray
        txt.textContainerInset = UIEdgeInsets(top: 10, left: 13, bottom: 8, right: 13)
        txt.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        txt.font = UIFont(name: "Helvetica", size: 18)
        txt.isScrollEnabled = false
        txt.isEditable = false
        return txt
    }()
   
    let v_stars: CosmosView = {
        let v = CosmosView()
        v.settings.updateOnTouch = false
        v.settings.filledImage = ratingStar.fill_18pt
        v.settings.emptyImage = ratingStar.empty_18pt
        v.settings.fillMode = .half
        v.settings.starSize = 17
        return v
    }()
    
    var reviewUid = ""
    
    override func prepareForReuse() {
        v_stars.prepareForReuse()
    }
    
    func init_review(reviewUid: String,
                     user_img: String,
                     username: String,
                     starRating: String,
                     text: String,
                     modifiedtime: String)
    {
        self.reviewUid = reviewUid
        //設定頭像
        [img_userIcon, lbl_username, v_stars, txt_comment, lbl_time].forEach{ self.addSubview($0) }
        
        img_userIcon.configureUserIcon(target: self, cornerRadious: 17.5, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: user_img, id: "uid:" + reviewUid, placeholder: UIImage(named: "user.png"))
       
        lbl_username.font = .systemFont(ofSize: 16)
        lbl_username.text = username
        txt_comment.text = text
        if text == "" { txt_comment.isScrollEnabled = true }
        else { txt_comment.isScrollEnabled = false }
        v_stars.rating = Double(starRating)!
        //設定時間
        lbl_time.text = modifiedtime
        setupAnchors()
    }
    
    func setupAnchors() {
        img_userIcon.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 20, bottom: 0, right: 0),size: CGSize(width: 35, height: 35))
        lbl_username.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 0, left: 68, bottom: 0, right: 0), size: CGSize(width: 0, height: 22))
        v_stars.anchor(top: lbl_username.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 3, left: 68, bottom: 0, right: 0), size: CGSize(width: 0, height: 17))
        txt_comment.anchor(top: v_stars.bottomAnchor, leading: img_userIcon.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 15))
        txt_comment.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: 20).isActive = true
        lbl_time.anchor(top: txt_comment.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 5, left: 200, bottom: 0, right: 29))
    }
    
    @objc func showUser() {
        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UserProfileNavi") as! UserProfileNavi
        vc.uid = self.reviewUid
        vc.isPresent = true
        self.findViewController()?.present(vc,animated: true)
    }
}

