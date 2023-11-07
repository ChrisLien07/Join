//
//  PostHomePageCVCell.swift
//  join
//
//  Created by ChrisLien on 2020/12/23.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class PostHomePageCVCell: UICollectionViewCell {
    
    let v_main: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    let img_pic: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()
    
    let lbl_text: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let lbl_comt_cnt: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb149Gray
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()
    
    let lbl_gp : UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb149Gray
        lbl.font = .systemFont(ofSize: 12)
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    let img_userIcon = UIImageView()
    var pid = ""
    var uid = ""

    func init_cell(postHPData: PostHPData,
                   width:CGFloat,
                   height:CGFloat)
    {
        self.pid = postHPData.pid
        self.uid = postHPData.uid
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tap)
        let tapGp = UITapGestureRecognizer.init(target: self, action: #selector(goGpPage))
        lbl_gp.addGestureRecognizer(tapGp)
        //
        configureBoard(postHPData: postHPData)
        setAnchors(width: width, height: height)
    }
    
    func setAnchors(width: CGFloat, height: CGFloat) {
        self.addSubview(v_main)
        [img_pic,lbl_text,img_userIcon,lbl_gp,lbl_comt_cnt].forEach { v_main.addSubview($0) }
        v_main.anchor(top: self.topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        img_pic.anchor(top: v_main.topAnchor, leading: v_main.leadingAnchor, bottom: nil, trailing: nil,size: CGSize(width: width, height: height*0.7))
        img_userIcon.anchor(top: img_pic.bottomAnchor, leading: v_main.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 7, left: 7, bottom: 0, right: 0),size: CGSize(width: 30, height: 30))
        lbl_gp.anchor(top: nil, leading: v_main.leadingAnchor, bottom: v_main.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 12, bottom: 5.5, right: 0),size: CGSize(width: 60, height: 20))
        lbl_comt_cnt.anchor(top: nil, leading: lbl_gp.trailingAnchor, bottom: v_main.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 0, bottom: 4, right: 0),size: CGSize(width: 60, height: 20))
        lbl_text.frame = CGRect(x: 49, y: height*0.7 + 8 , width: width - 49 - 9, height: 100)
        lbl_text.sizeToFit()
    }
    
    func configureBoard(postHPData: PostHPData) {
        if postHPData.img_url.contains("/Video") {
            let tmpimg = postHPData.img_url.replacingOccurrences(of: "/Video", with: "/Image")
            DownloadImage(view: img_pic, img: tmpimg.replacingOccurrences(of: "mp4", with: "jpg"), id: "pid:" + pid, placeholder: nil)
        } else {
            DownloadImage(view: img_pic , img: postHPData.img_url, id: "pid:" + pid, placeholder: nil )
        }
        img_userIcon.configureUserIcon(target: self, cornerRadious: 15, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: postHPData.user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        lbl_text.text = postHPData.text
        lbl_gp.addIconToLabel(img: BasicIcons.thumb!, labelText: postHPData.gp, bounds_x: -1, bounds_y: -3.5, boundsWidth: 18, boundsHeight: 18)
        lbl_comt_cnt.addIconToLabel(img: BasicIcons.chat_black!, labelText: postHPData.comt_cnt, bounds_x: -1, bounds_y: -5, boundsWidth: 18, boundsHeight: 18)
    }
    
    @objc func showUser() {
        let vc = findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = uid
        findViewController()!.hideMainBar()
        findViewController()!.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goGpPage() {
        let vc = findViewController()!.storyboard?.instantiateViewController(withIdentifier: "UserListCell") as! UserListTableVC
        vc.pid = pid
        vc.from = "gp"
        findViewController()!.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapped() {
        let Navi = findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Pi_FullPostNavi") as! Pi_FullPostNavi
        Navi.pid = pid
        Navi.uid = uid
        findViewController()!.present(Navi, animated: true, completion: nil)
    }
}
