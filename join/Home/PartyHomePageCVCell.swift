//
//  PartyHomePageCVCell.swift
//  join
//
//  Created by ChrisLien on 2020/12/23.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class PartyHomePageCVCell: UICollectionViewCell {

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
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    let lbl_starttime: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb149Gray
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()
    
    let lbl_adress: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Colors.rgb149Gray
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()
    
    let lbl_budget_label: UILabel = {
        let lbl = UILabel()
        lbl.text = "我買單"
        lbl.font = UIFont(name: ".PingFang-TC-Medium", size: 14)
        lbl.textColor = .white
        lbl.layer.cornerRadius = 10
        return lbl
    }()
    let v_budget_label: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    let img_userIcon = UIImageView()
  
    var ptid = ""
    var uid = ""

    func init_cell(partyHPData:PartyHPData,
                   width:CGFloat,
                   height:CGFloat)
    {
        self.uid = partyHPData.uid
        self.ptid = partyHPData.ptid
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        addSubview(v_main)
        [img_pic,lbl_text,img_userIcon,lbl_starttime,lbl_adress].forEach { v_main.addSubview($0) }
        [v_budget_label,lbl_budget_label].forEach { img_pic.addSubview($0) }
        configureBoard(partyHPData: partyHPData)
        configure_budget_label(budget_label: partyHPData.budget_label)
        setAnchors(width: width, height: height)
    }
    
    func setAnchors(width:CGFloat, height:CGFloat) {
        v_main.anchor(top: self.topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        img_pic.anchor(top: v_main.topAnchor, leading: v_main.leadingAnchor, bottom: nil, trailing: nil,size: CGSize(width: width, height: height*0.65))
        img_userIcon.anchor(top: img_pic.bottomAnchor, leading: v_main.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 7, left: 7, bottom: 0, right: 0),size: CGSize(width: 30, height: 30))
        lbl_adress.anchor(top: nil, leading: v_main.leadingAnchor, bottom: v_main.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 10, bottom: 10, right: 0),size: CGSize(width: width - 24, height: 15))
        lbl_starttime.anchor(top: nil, leading: v_main.leadingAnchor, bottom: lbl_adress.topAnchor, trailing: nil,padding: .init(top: 0, left: 10, bottom: 2, right: 0),size: CGSize(width: width - 24, height: 15))
        lbl_text.frame = CGRect(x: 49, y: height*0.65 + 8 , width: width - 49 - 9, height: 100)
        lbl_text.sizeToFit()
    }
    
    func configureBoard(partyHPData:PartyHPData) {
        img_userIcon.configureUserIcon(target: self, cornerRadious: 15, selector: #selector(showUser))
        DownloadImage(view: img_pic , img: partyHPData.img_url, id: "ptid:" + ptid, placeholder: nil )
        DownloadImage(view: img_userIcon, img: partyHPData.user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        lbl_text.text = partyHPData.title
        lbl_starttime.addIconToLabel(img: UIImage(named: "baseline_query_builder_black_24pt")!, labelText: changeformat2(string: partyHPData.starttime, part: "all"), bounds_x: -1, bounds_y: -2, boundsWidth: 14, boundsHeight: 14)
        lbl_adress.addIconToLabel(img: UIImage(named: "baseline_place_black_24pt")!, labelText: partyHPData.address, bounds_x: -1, bounds_y: -2, boundsWidth: 14, boundsHeight: 14)
    }
    
    func configure_budget_label(budget_label: String) {
        v_budget_label.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
        lbl_budget_label.frame = CGRect(x: 9, y: 2.5, width: 45, height: 20)
        if budget_label != "" {
            v_budget_label.isHidden = false
            lbl_budget_label.isHidden = false
            v_budget_label.maskedCornersGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1), #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: 10)
        } else {
            v_budget_label.isHidden = true
            lbl_budget_label.isHidden = true
        }
    }
    
    @objc func showUser() {
        let vc = findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        vc.uid = uid
        findViewController()!.hideMainBar()
        findViewController()!.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapped() {
        let Navi = findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
        Navi.ptid = ptid
        Navi.isHit = "1"
        Navi.uid = uid
        findViewController()!.present(Navi, animated: true, completion: nil)
    }
}
