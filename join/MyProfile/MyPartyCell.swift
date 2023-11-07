//
//  MyPartyCell.swift
//  join
//
//  Created by ChrisLien on 2020/10/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MyPartyCell: UITableViewCell {

    let v_main = UIView()
    let img_post = UIImageView()
    let lbl_yyyy =  UILabel()
    let lbl_MMdd =  UILabel()
    let lbl_daytime = UILabel()
    let lbl_title = UILabel()
    let lbl_adress = UILabel()
    let v_line = UIView()
    
    var isExpired = ""
    var ptid = ""
    var uid = ""
    func initParty(ptid: String,
                        uid: String,
                        img_url: String,
                        title: String,
                        starttime: String,
                        address: String,
                        isExpired: String,
                        height: CGFloat,
                        width: CGFloat)
    {
        self.isExpired = isExpired
        self.ptid = ptid
        self.uid = uid
        self.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        //
        v_main.frame = CGRect(x:15 ,y:0 ,width: width ,height: height)
        v_main.setupShadow(offsetWidth: 5, offsetHeight: 5, opacity: 0.05, radius: 3)
        v_main.backgroundColor = .white
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.postTouched(_:)))
        v_main.addGestureRecognizer(tap)
        v_main.layer.cornerRadius = v_main.frame.height/24
        self.addSubview(v_main)
        //設置圖片
        img_post.frame = CGRect(x: 0, y: 0, width: width, height: height*0.6)
        DownloadImage(view: img_post, img: img_url, id: "ptid:" + ptid, placeholder: nil)
        img_post.contentMode = .scaleAspectFill
        img_post.clipsToBounds = true
        v_main.addSubview(img_post)
        //設定文字
        lbl_title.frame = CGRect(x: 90, y: height*0.6 + 26, width: width - 95, height: 21)
        lbl_title.text = title
        lbl_title.font = .boldSystemFont(ofSize: 15)
        lbl_title.textColor = .black
        v_main.addSubview(lbl_title)
        //
        v_line.frame = CGRect(x: 75, y: height*0.6 + 25, width: 1, height: 25)
        v_line.backgroundColor = Colors.rgb188Gray
        v_main.addSubview(v_line)
        //設定時間
        lbl_yyyy.frame = CGRect(x:25,y:height*0.6 + 12,width: 30,height: 14)
        lbl_yyyy.text = changeformat2(string: starttime, part: "yyyy")
        lbl_yyyy.font = .systemFont(ofSize: 10)
        lbl_yyyy.textColor = Colors.rgb149Gray
        v_main.addSubview(lbl_yyyy)
        //
        lbl_MMdd.frame = CGRect(x: 11,y:height*0.6 + 24,width: 52,height: 25)
        lbl_MMdd.text = changeformat2(string: starttime, part: "MM/dd")
        lbl_MMdd.font = .boldSystemFont(ofSize: 18)
        lbl_MMdd.textColor = UIColor.black.withAlphaComponent(0.75)
        v_main.addSubview(lbl_MMdd)
        //
        lbl_daytime.frame = CGRect(x: 15, y: height*0.6 + 48, width: 50, height: 14)
        lbl_daytime.text = changeformat2(string: starttime, part: "daytime")
        lbl_daytime.font = .systemFont(ofSize: 10)
        lbl_daytime.textColor = Colors.rgb149Gray
        v_main.addSubview(lbl_daytime)
        //設定地址
        lbl_adress.frame = CGRect(x:90,y:lbl_title.frame.origin.y + lbl_title.frame.height + 5 ,width: 180,height: 14)
        lbl_adress.text = address
        lbl_adress.font = .boldSystemFont(ofSize: 10)
        lbl_adress.textColor = Colors.rgb149Gray
        v_main.addSubview(lbl_adress)
    }
    
    @objc func postTouched(_ sender:UIGestureRecognizer){
        let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
        Navi.ptid = ptid
        Navi.uid = uid
        if self.isExpired == "1" {
            Navi.isExpired = true
        }
        self.findViewController()!.present(Navi, animated: true, completion: nil)
    }
}
