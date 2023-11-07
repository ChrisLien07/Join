//
//  SearchTableCell.swift
//  join
//
//  Created by 連亮涵 on 2020/6/9.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SearchTableCell: UITableViewCell {

    let v_result = UIView()
    let img_post = UIImageView()
    let lbl_title = UILabel()
    let lbl_yyyy =  UILabel()
    let lbl_MMdd =  UILabel()
    let lbl_daytime = UILabel()
    let lbl_adress = UILabel()
    let v_line = UIView()

    var ptid = ""
    
    func initSearch(ptid: String,
                    uid: String,
                    img_url: String,
                    title: String,
                    starttime: String,
                    address: String,
                    height: CGFloat,
                    width: CGFloat)
    {
        self.ptid = ptid
        v_result.frame = CGRect(x:15,y:0,width: width,height: height)
        v_result.setupShadow(offsetWidth: 5, offsetHeight: 5, opacity: 0.05, radius: 3)
        v_result.backgroundColor = .white
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.postTouched(_:)))
        v_result.addGestureRecognizer(tap)
        self.addSubview(v_result)
        //設置圖片
        img_post.frame = CGRect(x: 0, y: 0, width: width, height: height*0.6)
        img_post.layer.cornerRadius = 10
        img_post.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        DownloadImage(view: img_post, img: img_url, id: "ptid:" + ptid, placeholder: nil)
        
        img_post.contentMode = .scaleAspectFill
        img_post.clipsToBounds = true
        v_result.addSubview(img_post)
        v_result.layer.cornerRadius = v_result.frame.height/24
        //設定文字
        lbl_title.frame = CGRect(x: 90, y: height*0.6 + 16, width: width - 95, height: 21)
        lbl_title.text = title
        lbl_title.font = .boldSystemFont(ofSize: 16)
        lbl_title.textColor = .black
        v_result.addSubview(lbl_title)
        //
        v_line.frame = CGRect(x: 75, y: height*0.6 + 25, width: 1, height: 25)
        v_line.backgroundColor = Colors.rgb188Gray
        v_result.addSubview(v_line)
        //設定時間
        lbl_yyyy.frame = CGRect(x:25,y:height*0.6 + 12,width: 30,height: 14)
        lbl_yyyy.text = changeformat2(string: starttime, part: "yyyy")
        lbl_yyyy.font = .systemFont(ofSize: 12)
        lbl_yyyy.textColor = Colors.rgb149Gray
        v_result.addSubview(lbl_yyyy)
        //
        lbl_MMdd.frame = CGRect(x: 11,y:height*0.6 + 24,width: 52,height: 25)
        lbl_MMdd.text = changeformat2(string: starttime, part: "MM/dd")
        lbl_MMdd.font = .boldSystemFont(ofSize: 18)
        lbl_MMdd.textColor = UIColor.black.withAlphaComponent(0.75)
        v_result.addSubview(lbl_MMdd)
        //
        lbl_daytime.frame = CGRect(x: 12, y: height*0.6 + 48, width: 60, height: 14)
        lbl_daytime.text = changeformat2(string: starttime, part: "daytime")
        lbl_daytime.font = .systemFont(ofSize: 12)
        lbl_daytime.textColor = Colors.rgb149Gray
        v_result.addSubview(lbl_daytime)
        //設定地址
        lbl_adress.frame = CGRect(x:90,y:lbl_title.frame.origin.y + lbl_title.frame.height + 5 ,width: 180,height: 14)
        lbl_adress.text = address
        lbl_adress.lineBreakMode = .byClipping
        lbl_adress.font = .boldSystemFont(ofSize: 14)
        lbl_adress.textColor = Colors.rgb149Gray
        v_result.addSubview(lbl_adress)
    }
    
    @objc func postTouched(_ sender:UIGestureRecognizer){
        
        let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
        Navi.ptid = ptid
        self.findViewController()!.present(Navi, animated: true, completion: nil)
    }

}
