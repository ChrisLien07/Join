//
//  Pi_CommentView.swift
//  join
//
//  Created by 連亮涵 on 2020/6/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Agrume
import UIView_TouchHighlighting

class CommentView: UIView {
        
    let v_Comment = UIView()
    let lbl_UserName = UILabel()
    let img_UserIcon = UIImageView()
    let btn_Reply = UIButton()
    let lbl_Time = UILabel()
    let v_TextBackGround = UIView()
    let txt_CommentText = UITextView()
    let imgView = UIImageView()
    let v_line = UIView()
    
    var pid = ""
    var ptid = ""
    var uid = ""
    var cmtid = ""
    var username = ""
    var comtArray: [Comt] = []
    var CommentHeight: CGFloat = 0
    var from = ""
    
    func initwithComments(username: String,
                          user_img: String,
                          text: String,
                          createtime: String,
                          comtArr: [Comt],
                          cmtid: String,
                          uid: String,
                          y: CGFloat,
                          width:CGFloat,
                          pid: String,
                          ptid: String,
                          from: String)
    {
        self.cmtid = cmtid
        self.username = username
        self.uid = uid
        self.ptid = ptid
        self.from = from
        //設定頭像
        img_UserIcon.frame = CGRect(x:20,y:15,width: 45,height: 45)
        img_UserIcon.configureUserIcon(target: self, cornerRadious: 22.5, selector: #selector(showUser))
        DownloadImage(view: img_UserIcon, img: user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        v_Comment.addSubview(img_UserIcon)
        //設定暱稱
        lbl_UserName.frame = CGRect(x:15,y:10,width: width - 170,height: 20)
        lbl_UserName.text = username
        lbl_UserName.textAlignment = .natural
        lbl_UserName.font = .boldSystemFont(ofSize: 13)
        lbl_UserName.textColor = UIColor.black
        lbl_UserName.sizeToFit()
        v_TextBackGround.addSubview(lbl_UserName)
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
        v_TextBackGround.frame = CGRect(x:70,y:10,width: max(txt_CommentText.frame.width,lbl_UserName.frame.width) + 30,height: txt_CommentText.frame.height + 40)
        v_TextBackGround.backgroundColor = .groupTableViewBackground
        v_TextBackGround.layer.cornerRadius = 10
        v_Comment.addSubview(v_TextBackGround)
        //設定回覆按鈕
        btn_Reply.frame = CGRect(x: 80, y: v_TextBackGround.frame.origin.y + v_TextBackGround.frame.height + 5, width: 40 ,height: 20)
        btn_Reply.setTitle("回覆", for: .normal)
        btn_Reply.titleLabel?.font = .boldSystemFont(ofSize: 14)
        btn_Reply.setTitleColor(UIColor.black.withAlphaComponent(0.75), for: .normal)
        btn_Reply.addTarget(self, action: #selector(changeTextInput), for: .touchDown)
        v_Comment.addSubview(btn_Reply)
        //設定時間
        lbl_Time.frame = CGRect(x:135,y:btn_Reply.frame.origin.y,width: 150,height: 20)
        lbl_Time.text = createtime
        lbl_Time.textAlignment = .natural
        lbl_Time.font = .systemFont(ofSize: 13)
        lbl_Time.textColor = UIColor.black.withAlphaComponent(0.4)
        v_Comment.addSubview(lbl_Time)
        //
        v_Comment.frame = CGRect(x:0,y:0 , width:width, height: v_TextBackGround.frame.origin.y + v_TextBackGround.frame.height + 25)
        v_Comment.touchHighlightingStyle = .lightBackground
        self.addSubview(v_Comment)
        //
        v_line.frame = CGRect(x: 0, y: below(btn_Reply) + 6, width: width, height: 0.5)
        v_line.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        //v_Comment.addSubview(v_line)
        //
        CommentHeight = btn_Reply.frame.origin.y + btn_Reply.frame.height
        setSubComments(comtArr,width: width)

        self.frame = CGRect(x: 0, y: y, width: width, height: CommentHeight + 10)
    }

    func setSubComments(_ comtArr: [Comt],width: CGFloat) {
        for co in comtArr {
            let subCommentView = SubCommentView().initSubComment(username: co.username, user_img: co.user_img, text: co.text, creattime: co.createtime, x: 0, y:self.CommentHeight, width:width, pid: pid, ptid: ptid, uid: co.uid)
            self.addSubview(subCommentView)
            CommentHeight += subCommentView.frame.height
        }
    }
    
    @objc func changeTextInput() {
        
        let tmpCombine = Combine()
        tmpCombine.id = uid
        tmpCombine.txt = "@" + username + " "
        
        if  let vc = self.findViewController() as? Pi_FullPostVC {
            
            vc.subComtText = true
            vc.fatherCmtid =  cmtid
            vc.txt_Input.text = "回覆\(username)的留言"
            vc.txt_Input.textColor = UIColor.lightGray
            
        } else if let vc = self.findViewController() as? Jo_FullPostVC {
            if vc.isPublic == "0" {
                NetworkManager.shared.callCheckUserAttendanceService(ptid: ptid, atUid: uid) { [self] (code, msg) in
                    switch code {
                    case 0:
                        if vc.txt_Input.text != vc.placehoalderText {
                            vc.txt_Input.text = "@\(username) " + vc.txt_Input.text
                        } else {
                            vc.txt_Input.text = "@\(username) "
                        }
                        vc.replyCmt.append(tmpCombine)
                        vc.txt_Input.textColor = UIColor.black.withAlphaComponent(0.75)
                    case 149:
                        Alert.atPersonLeavePartyAlert(vc: findViewController()!, username: username)
                    default:
                        break
                    }
                }
            } else {
                if vc.txt_Input.text != vc.placehoalderText {
                    vc.txt_Input.text = "@\(username) " + vc.txt_Input.text
                } else {
                    vc.txt_Input.text = "@\(username) "
                }
                vc.replyCmt.append(tmpCombine)
                vc.txt_Input.textColor = UIColor.black.withAlphaComponent(0.75)
            }
            
        } else if let vc = self.findViewController() as? GroupChatBoardVC {
        
            NetworkManager.shared.callCheckUserAttendanceService(ptid: ptid, atUid: uid) { [self] (code, msg) in
                switch code {
                case 0:
                    if vc.txt_input.text != vc.placehoalderText {
                        vc.txt_input.text = "@\(username) " + vc.txt_input.text
                    } else {
                        vc.txt_input.text = "@\(username) "
                    }
                    vc.replyCmt.append(tmpCombine)
                    vc.txt_input.textColor = UIColor.black.withAlphaComponent(0.75)
                case 149:
                    Alert.atPersonLeavePartyAlert(vc: findViewController()!, username: username)
                default:
                    break
                }
            }
        }
    }
    
    @objc func showUser() {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            userInfoVC.uid = uid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
}
