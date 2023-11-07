//
//  MemberViewCell.swift
//  join
//
//  Created by ChrisLien on 2020/12/3.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MemberViewCell: UICollectionViewCell {

    let img_userIcon = UIImageView()
    
    let lbl_username: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0, y: 45, width: 45, height: 25))
        lbl.font = .systemFont(ofSize: 11)
        lbl.textAlignment = .center
        lbl.textColor = .black
        return lbl
    }()
    
    var uid = ""
    
    func init_cell(username: String,
                   img_url: String,
                   uid: String)
    {
        self.uid = uid
        img_userIcon.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        setupSubViews(username: username, img_url: img_url)
    }
    
    func setupSubViews(username: String, img_url: String) {
        img_userIcon.configureUserIcon(target: self, cornerRadious: 22.5, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: img_url, id: "uid:" + uid, placeholder: .none)
        lbl_username.text = username
        self.addSubview(lbl_username)
        self.addSubview(img_userIcon)
    }
    
    @objc func showUser() {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            userInfoVC.uid = uid
            self.findViewController()!.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
    
}
