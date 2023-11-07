//
//  GroupChatBoardVC.swift
//  join
//
//  Created by ChrisLien on 2020/11/9.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class GroupChatBoardVC: UIViewController {

    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var v_board: UIView!
    @IBOutlet weak var v_input: UIView!
    @IBOutlet weak var txt_input: UITextView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var btn_goPost: UIBarButtonItem!
    
    let v_member = MemberView()
    
    var commentsCount = 0
    var commentsHeight : CGFloat = 0
    var membersHeight: CGFloat = 0
    var keyBoardHeight : CGFloat = 0
    var rect: CGRect?
    
    var keyBoardShow = false
    var participant_arry: [AttendanceList] = []
    
    
    var ptid = ""
    var username = ""
    var user_img = ""
    var uid = ""
   
    var from = ""
    let placehoalderText = "輸入留言..."
    
    var replyCmt: [Combine] = []
    
    var scrolltoComt = false
    var scrollCmtid = ""
    var scroll_y: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //
        if from == "notification" {
            hideMainBar()
        } else {
            btn_goPost.title = ""
        }
        //
        txt_input.delegate = self
        txt_input.text = placehoalderText
        txt_input.textColor = UIColor.lightGray
        txt_input.layer.borderWidth = 1
        txt_input.layer.borderColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        txt_input.layer.cornerRadius = txt_input.frame.height/2
        txt_input.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 35)
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.postTouched(_:)))
        sv_main.addGestureRecognizer(tap)
       
        sv_main.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: sv_main.superview?.leadingAnchor, bottom: v_input.topAnchor, trailing: sv_main.superview?.trailingAnchor)
    
        getPartyComt(scrollBottom: false, loadmore: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.endEdit()
        super.viewWillDisappear(animated)
    }
    
    func getPartyComt(scrollBottom: Bool,loadmore: Bool) {
        NetworkManager.shared.callGetPartyComtService(ptid: ptid, isPublic: "0") { (code, respondJsonList, msg) in
            switch code {
            case 0:
                self.clearComments()
                self.setMembers()
                
                for cos in respondJsonList!
                {
                    let tmpComts = Comts()
                    parseComts(comts:tmpComts,cos:cos)
                    self.setComments(cos: tmpComts)
                }
                
                self.resetHeights()
                
                if scrollBottom {
                    self.sv_main.setContentOffset(CGPoint(x: 0,y: max(self.sv_main.contentSize.height - self.sv_main.frame.height, 0)), animated: true)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                self.clearComments()
                
                self.setMembers()
                
                self.resetHeights()
                
                if scrollBottom {
                    self.sv_main.setContentOffset(CGPoint(x: 0,y: max( self.sv_main.contentSize.height - self.sv_main.frame.height,0)), animated: true)
                }
                
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }

    func callCommentService(atUidArray: [String])
    {
        let newText = txt_input.text.replacingOccurrences(of: "+", with: "%2B")
        let atUid = atUidArray.joined(separator: ",")
        
        let request = createHttpRequest(Url: globalData.NewPtComtFUrl , HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&text=\(newText)&isPublic=\("0")&atUid=\(atUid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                self.btn_send.isEnabled = true
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    self.btn_send.isEnabled = true
                    if responseJSON["code"] as! Int == 0
                    {
                        self.txt_input.text = ""
                        self.textViewDidEndEditing(self.txt_input)
                        self.getPartyComt(scrollBottom: true, loadmore: false)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }

    func setComments(cos: Comts) {
        //設置留言
        commentsCount += 1
        let commentsView = CommentView()
        commentsView.initwithComments(username:cos.username, user_img:cos.user_img, text:cos.text, createtime:cos.createtime, comtArr: cos.comtArr, cmtid: cos.cmtid, uid: cos.uid, y: commentsHeight, width: v_board.frame.width,pid: "", ptid: ptid, from: "groupBoard")
        v_board.addSubview(commentsView)
        
        commentsHeight += commentsView.frame.height
        
        if  scrollCmtid == cos.cmtid {
            scroll_y = commentsHeight
        }
    }
    
    func setMembers() {
        sv_main.addSubview(v_member)
        print(uid)
        v_member.init_view(hostName: username, hostIcon: user_img, ptid: ptid, uid: uid, attendance: participant_arry.count, width: view.frame.width)
    
        self.membersHeight = v_member.frame.height
    }
    
    func resetHeights() {
        //載入完成後調整高度
        v_member.frame = CGRect(x: 0, y: 15, width: view.frame.width, height: membersHeight)
        v_board.frame = CGRect(x: 0, y: below(v_member), width: view.frame.width, height: commentsHeight)
        sv_main.contentSize = CGSize(width: view.frame.width, height: v_board.frame.origin.y + commentsHeight)
        
        if scrolltoComt {
            sv_main.setContentOffset(CGPoint(x: 0,y: max((v_board.frame.origin.y + scroll_y) - sv_main.frame.height  ,0)), animated: true)
            
            scrolltoComt = false
        }
    }

    func clearComments() {
        for v in self.v_board.subviews { v.removeFromSuperview()}
        commentsCount = 0
        commentsHeight = 0
    }

    @IBAction func sendComment(_ sender: Any ) {
        
        var tagPeople: [String] = []
        txt_input.resignFirstResponder()
        if txt_input.textColor == UIColor.black.withAlphaComponent(0.75) && txt_input.text!.count > 0 {
            self.btn_send.isEnabled = false
            for cmt in replyCmt {
                if txt_input.text.contains(cmt.txt) {
                    tagPeople.append(cmt.id)
                }
            }
            self.callCommentService(atUidArray: tagPeople)
        } else {
            shortInfoMsg(msg: "請輸入留言內容", vc: self, sec: 2)
        }
    }

    @objc func postTouched(_ sender:UIGestureRecognizer){
        //結束文字編輯
        txt_input.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        guard let userInfo = (notification as Notification).userInfo, let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyBoardHeight = value.cgRectValue.height
        if !keyBoardShow {
            view.frame.size.height -= keyBoardHeight
            keyBoardShow = true
        }
    }
         
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyBoardShow {
            view.frame.size.height += keyBoardHeight
            keyBoardShow = false
        }
    }
    
    @objc func KeyboardHeightChanged(_ notification: Notification){
        
        let keyboardSize1 = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        if keyBoardShow == true && keyBoardHeight != keyboardSize1.height {
            if keyBoardHeight < keyboardSize1.height{
                let keyboardDifference: CGFloat = keyboardSize1.height - keyBoardHeight
                view.frame.size.height -= keyboardDifference

            } else {
                let keyboardDifference: CGFloat = keyBoardHeight - keyboardSize1.height
                view.frame.size.height += keyboardDifference
            }
            keyBoardHeight = keyboardSize1.height
        }
    }

    @IBAction func goPost(_ sender: Any) {
        let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Jo_FullPostNavi") as! Jo_FullPostNavi
        Navi.ptid = ptid
        Navi.uid = uid
        self.findViewController()!.present(Navi, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        if from == "notification" {
            (self.findTabBarController() as! MainTabBar).tabBar.isHidden = false
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroupChatBoardVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        //開始編輯後去除placeholder
        if  textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black.withAlphaComponent(0.75)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView)
    {
        //結束編輯後依字數生成placeholder
        if  !textView.hasText {
            textView.text = placehoalderText
            textView.textColor = UIColor.lightGray
        }
    }
}
