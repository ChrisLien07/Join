//
//  Pi_SubCommentView.swift
//  join
//
//  Created by 連亮涵 on 2020/6/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Agrume
import UIView_TouchHighlighting
class SubCommentView: UIView {
    
    let lbl_userName = UILabel()
    let img_UserIcon = UIImageView()
    let txt_CommentText = UITextView()
    let lbl_Time = UILabel()
    let v_TextBackGround = UIView()
    let imgView = UIImageView()
    
    var CommentHeight : CGFloat = 0
    var serial = ""
    var pid = ""
    var ptid = ""
    var num = ""
    var uid = ""
    func initSubComment(username: String,
                        user_img: String,
                        text: String,
                        creattime: String,
                        x:CGFloat,
                        y: CGFloat,
                        width:CGFloat,
                        pid: String,
                        ptid: String,
                        uid: String) -> UIView
    {
        //設定頭像
        self.pid = pid
        self.ptid = ptid
        self.uid = uid
        img_UserIcon.frame = CGRect(x:80,y:15,width: 35,height: 35)
        img_UserIcon.configureUserIcon(target: self, cornerRadious: 17.5, selector: #selector(showUser))
        DownloadImage(view: img_UserIcon, img: user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        self.addSubview(img_UserIcon)
        //設定暱稱
        lbl_userName.frame = CGRect(x:15,y:10,width: width - 150,height: 20)
        lbl_userName.text = username
        lbl_userName.textAlignment = .natural
        lbl_userName.font = .boldSystemFont(ofSize: 13)
        lbl_userName.textColor = UIColor.black
        lbl_userName.sizeToFit()
        v_TextBackGround.addSubview(lbl_userName)
        //設定文字
        txt_CommentText.frame = CGRect(x:15,y:30,width: width - 170,height: 70)
        txt_CommentText.text = text
        txt_CommentText.textAlignment = .natural
        txt_CommentText.font = .systemFont(ofSize: 15)
        txt_CommentText.textColor = UIColor.black.withAlphaComponent(0.75)
        txt_CommentText.backgroundColor = .none
        txt_CommentText.translatesAutoresizingMaskIntoConstraints = true
        txt_CommentText.textContainerInset = .zero
        txt_CommentText.textContainer.lineFragmentPadding = 0
        txt_CommentText.sizeToFit()
        txt_CommentText.isScrollEnabled = false
        txt_CommentText.isEditable = false
        v_TextBackGround.addSubview(txt_CommentText)
        //設定文字背景
        v_TextBackGround.frame = CGRect(x:120,y:10,width: max(txt_CommentText.frame.width,lbl_userName.frame.width) + 30,height: txt_CommentText.frame.height + 40)
        v_TextBackGround.backgroundColor = .groupTableViewBackground
        v_TextBackGround.layer.cornerRadius = 10
        self.addSubview(v_TextBackGround)
        //設定時間
        lbl_Time.frame = CGRect(x: 135, y: v_TextBackGround.frame.origin.y + v_TextBackGround.frame.height + 5, width: 150 ,height: 20)
        lbl_Time.text = creattime
        lbl_Time.textAlignment = .natural
        lbl_Time.font = .systemFont(ofSize: 13)
        lbl_Time.textColor = UIColor.black.withAlphaComponent(0.4)
        self.addSubview(lbl_Time)
        self.touchHighlightingStyle = .lightBackground
        CommentHeight = lbl_Time.frame.origin.y + lbl_Time.frame.height

        self.frame = CGRect(x: x, y: y, width: width, height: CommentHeight)
        
        return self
    }
    
    @objc func showUser() {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            userInfoVC.uid = uid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
}
