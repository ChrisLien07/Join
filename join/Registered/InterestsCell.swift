//
//  InterestsViewCell.swift
//  join
//
//  Created by 連亮涵 on 2020/5/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class InterestsViewCell: UICollectionViewCell {
    
    var img_pic = UIImageView()
    
    var img_checkmark: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "baseline_radio_button_unchecked_black_24pt")
        iv.tintColor = .black
        return iv
    }()
    
    var lbl_title: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
        lbl.textColor = UIColor.black.withAlphaComponent(0.75)
        return lbl
    }()
    
    func init_View(pic:UIImage , title:String, width: CGFloat) {
        [img_pic,img_checkmark,lbl_title].forEach{ addSubview($0) }
        setAnchors(width: width)
       
        img_pic.image = pic
        lbl_title.text = title
    }
    
    func setAnchors(width: CGFloat) {
        img_pic.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 5, bottom: 0, right: 0),size: CGSize(width: width - 20, height: width - 20))
        lbl_title.anchor(top: img_pic.bottomAnchor, leading: img_pic.leadingAnchor, bottom: bottomAnchor, trailing: nil,size: CGSize(width: width - 20, height: 0))
        img_checkmark.frame = CGRect(x: width - 30, y: width - 40, width: 25, height: 25)
        
    }
    
    func setSelected() {
        img_checkmark.image = UIImage(named: "baseline_check_circle_black_24pt")
    }
       
    func setDeselected() {
        img_checkmark.image = UIImage(named: "baseline_radio_button_unchecked_black_24pt")
    }
}
