//
//  Jo_FullPostVC.swift
//  join
//
//  Created by 連亮涵 on 2020/6/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import TLPhotoPicker
import MJRefresh

class Jo_FullPostVC: UIViewController,UIGestureRecognizerDelegate,TLPhotosPickerViewControllerDelegate {
    @IBOutlet weak var sv_Post: UIScrollView!
    @IBOutlet weak var v_Post: UIView!
    @IBOutlet weak var v_Comment: UIView!
    @IBOutlet weak var v_Input: UIView!
    @IBOutlet weak var txt_Input: UITextView!
    @IBOutlet weak var btn_Send: UIButton!
    @IBOutlet weak var btn_pic: UIButton!
    @IBOutlet weak var btn_Report: UIBarButtonItem!

    lazy var v_member = MemberView()
    
    var fullPost = Party()
    var TLConfig = TLPhotosPickerConfigure()
    var TLimgPicker = TLPhotosPickerViewController()
    let rc_head = MJRefreshNormalHeader()
    var participant_arry: [AttendanceList] = []
    var commentsCount = 0
    var commentsHeight: CGFloat = 0
    var membersHeight: CGFloat = 0
    var keyBoardHeight: CGFloat = 0
    var rect: CGRect?
    
    var keyBoardShow = false
    var isExpired = false
    
    var ptid = ""
    var uid = ""
    var isHit = ""
    
    var replyCmt: [Combine] = []
    
    var scrolltoComt = false
    var scrollCmtid = ""
    var scroll_y: CGFloat = 0
    
    var isPublic = "1"
    let placehoalderText = "輸入留言..."

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        TLimgPicker.delegate = self
        TLConfig.usedCameraButton = false
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
        //設定上下拉刷新功能
        rc_head.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        sv_Post.mj_header = rc_head
        rect = view.bounds
        //取得ptid
        if let navi = self.navigationController as? Jo_FullPostNavi {
            ptid = navi.ptid
            uid = navi.uid
            isExpired = navi.isExpired
            isHit = navi.isHit
            scrolltoComt = navi.scrolltoComt
            scrollCmtid = navi.cmtid
        }
       
        txt_Input.delegate = self
        txt_Input.text = placehoalderText
        txt_Input.textColor = UIColor.lightGray
        txt_Input.layer.borderWidth = 1
        txt_Input.layer.borderColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        txt_Input.layer.cornerRadius = txt_Input.frame.height/2
        txt_Input.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 35)
        //
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(postTouched(_:)))
        sv_Post.addGestureRecognizer(tap)
        //
        if #available(iOS 11.0, *) {
            sv_Post.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: sv_Post.superview?.leadingAnchor, bottom: v_Input.topAnchor, trailing: sv_Post.superview?.trailingAnchor)
        } else {
            sv_Post.anchor(top: sv_Post.superview?.topAnchor, leading: sv_Post.superview?.leadingAnchor, bottom: v_Input.topAnchor, trailing: sv_Post.superview?.trailingAnchor)
        }
        callPostService(refresh: false)
        getAttendanceList(ptid: ptid)
    }

    func callPostService(refresh: Bool)
    {
        if ptid != ""
        {
            let request = createHttpRequest(Url: globalData.GetPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&isHit=\(isHit)")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else
                {
                    Alert.ShowConnectErrMsg(vc: self)
                    DispatchQueue.main.async {
                        self.rc_head.endRefreshing()
                    }
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]
                {
                    DispatchQueue.main.async {
                        if responseJSON["code"] as! Int == 0
                        {
                            //匯入貼文資料
                            let jo = responseJSON["party"] as! [[String: Any]]
                            parsePostJo(party: self.fullPost, jo: jo[0])

                            self.isHit = "0"
                            //將貼文設置在畫面上
                            self.setPost()
                            if refresh {
                                self.getPartyComt(refresh: true, scrollBottom: false, loadmore: false)
                            } else {
                                self.getPartyComt(refresh: false, scrollBottom: false, loadmore: false)
                            }
                            
                            self.rc_head.endRefreshing()
                        }
                        else
                        {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                            self.rc_head.endRefreshing()
                        }
                    }
                }
            }
            task.resume()

        }
    }
    
    func getPartyComt(refresh: Bool, scrollBottom: Bool, loadmore: Bool) {
        NetworkManager.shared.callGetPartyComtService(ptid: ptid, isPublic: isPublic) { (code, respondJsonList, msg) in
            switch code {
            case 0:
                
                self.clearComments()
                
                if refresh {
                    self.isPublic = "1"
                }
                
                if self.isPublic == "0" {
                    self.setMembers()
                }
                
                for cos in respondJsonList!
                {
                    let tmpComts = Comts()
                    parseComts(comts:tmpComts,cos:cos)
                    self.setComments(cos: tmpComts)
                }
                
                self.resetHeights(isPublic: self.isPublic)
                
                if scrollBottom {
                    self.sv_Post.setContentOffset(CGPoint(x: 0,y: max( self.sv_Post.contentSize.height - self.sv_Post.frame.height,0)), animated: true)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                self.clearComments()
                
                if self.isPublic == "0" {
                    self.setMembers()
                }
                
                self.resetHeights(isPublic: self.isPublic)
                if scrollBottom {
                    self.sv_Post.setContentOffset(CGPoint(x: 0,y: max( self.sv_Post.contentSize.height - self.sv_Post.frame.height,0)), animated: true)
                }
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func reportParty(accuse_reason: String) {
        NetworkManager.shared.callReportService(target: "party", id: ptid, accuse_reason: accuse_reason) { (code, msg) in
            switch code {
            case 0:
                Alert.basicActionAlert(vc: self, title: "抱歉，造成您的不悅", message: "我們已經收到您的檢舉通知，客服人員會盡快處理。", okBtnTitle: "返回首頁", twoBtn: false) { (_) in
                    self.backtoHome(0)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code, msg: msg!,vc: self)
            }
        }
    }

    func callCommentService(atUidArray: [String])
    {
        let newText = txt_Input.text.replacingOccurrences(of: "+", with: "%2B")
        let atUid = atUidArray.joined(separator: ",")
        
        let request = createHttpRequest(Url: globalData.NewPtComtFUrl , HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&text=\(newText)&isPublic=\(isPublic)&atUid=\(atUid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                self.btn_Send.isEnabled = true
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    self.btn_Send.isEnabled = true
                    if responseJSON["code"] as! Int == 0
                    {
                        self.txt_Input.text = ""
                        self.textViewDidEndEditing(self.txt_Input)
                        self.getPartyComt(refresh: false, scrollBottom: true, loadmore: false)
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
    
    func getAttendanceList(ptid : String) {
        NetworkManager.shared.callGetAttendListService(ptid: ptid) { (code, list, msg) in

            self.participant_arry.removeAll()
            switch code {
            case 0:
                self.participant_arry = list!
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
               print("0")
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
            }
        }
    }

    func setPost() {
        //設置貼文
        let fullPostView = Jo_FullPostView()
        fullPostView.setPostData(ptid: ptid, uid: uid, fullPost: fullPost, participant_arry: participant_arry, width:v_Post.frame.width)
        v_Post.addSubview(fullPostView)
        v_Post.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: fullPostView.frame.height)
    }

    func setComments(cos: Comts) {
        //設置留言
        commentsCount += 1
        let commentsView = CommentView()
        commentsView.initwithComments(username:cos.username, user_img:cos.user_img, text:cos.text, createtime:cos.createtime, comtArr: cos.comtArr, cmtid: cos.cmtid, uid: cos.uid, y: commentsHeight, width: v_Comment.frame.width,pid: "", ptid: ptid, from: "jo")
        v_Comment.addSubview(commentsView)
        
        commentsHeight += commentsView.frame.height

        if  scrollCmtid == cos.cmtid {
            scroll_y =  commentsHeight
        }
    }
    
    
    func setMembers() {
        sv_Post.addSubview(v_member)
        print(uid)
        v_member.init_view(hostName: fullPost.username, hostIcon: fullPost.user_img, ptid: ptid, uid: uid, attendance: participant_arry.count, width: view.frame.width)

        membersHeight = v_member.frame.height
    }

    func resetHeights(isPublic: String) {
        //載入完成後調整高度
        if isPublic == "1" {
            v_member.removeFromSuperview()
            v_Comment.frame = CGRect(x: 0, y: v_Post.frame.height, width: view.frame.width, height: commentsHeight)
            sv_Post.contentSize = CGSize(width: view.frame.width, height: v_Post.frame.height + commentsHeight)
        } else {
            v_member.frame = CGRect(x: 0, y: v_Post.frame.origin.y + v_Post.frame.height, width: view.frame.width, height: membersHeight)
            v_Comment.frame = CGRect(x: 0, y: below(v_member), width: view.frame.width, height: commentsHeight)
            sv_Post.contentSize = CGSize(width: view.frame.width, height: v_Comment.frame.origin.y + commentsHeight)
        }
        
        if scrolltoComt {
            sv_Post.setContentOffset(CGPoint(x: 0,y: max((v_Comment.frame.origin.y + scroll_y) - sv_Post.frame.height  ,0)), animated: true)
            scrolltoComt = false
        }
    }

    func clearComments() {
        for v in self.v_Comment.subviews { v.removeFromSuperview()}
        commentsCount = 0
        commentsHeight = 0
    }

    @IBAction func backtoHome(_ sender: Any)
    {
        let count = self.navigationController?.viewControllers.count
        if count! > 1 {
            (self.findTabBarController() as! MainTabBar).tabBar.isHidden = false
            self.navigationController!.popViewController(animated: true)
        }
        else {
            self.navigationController!.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func report(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportHandler = { (action:UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "檢舉聚會", message: nil, preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "這是一則垃圾廣告", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "001")
            }))
            alertMessage.addAction(UIAlertAction(title: "詐騙行為", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "002")
            }))
            alertMessage.addAction(UIAlertAction(title: "直銷活動", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "003")
            }))
            alertMessage.addAction(UIAlertAction(title: "這是散播暴力、色情、令人不舒服等不當資訊", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "004")
            }))
            alertMessage.addAction(UIAlertAction(title: "聚會變更、取消未通知", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "005")
            }))
            alertMessage.addAction(UIAlertAction(title: "其他", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportParty(accuse_reason: "006")
            }))
            alertMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alertMessage,animated: true, completion: nil)
        }
        let reportAction = UIAlertAction(title: "檢舉此聚會", style: .destructive, handler: reportHandler)
        
        let shareAction = UIAlertAction(title: "分享聚會", style: .default, handler: {(action:UIAlertAction!) -> Void in
            let defaultText = "https://www.bc9in.com/web/party.html?ptid=\(self.ptid)"
            let activity = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu,animated: true, completion: nil)
    }

    @IBAction func SendComment(_ sender: Any )
    {
        var tagPeople: [String] = []
        txt_Input.resignFirstResponder()
        if txt_Input.textColor == UIColor.black.withAlphaComponent(0.75) && txt_Input.text!.count > 0 {
            self.btn_Send.isEnabled = false
            for cmt in replyCmt {
                if txt_Input.text.contains(cmt.txt) {
                    tagPeople.append(cmt.id)
                }
            }
            callCommentService(atUidArray: tagPeople)
        } else {
            shortInfoMsg(msg: "請輸入留言內容", vc: self, sec: 2)
        }
    }

    @objc func refresh() {
        callPostService(refresh: true)
    }
    
    @objc func postTouched(_ sender:UIGestureRecognizer){
        txt_Input.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
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
    
    @objc func KeyboardHeightChanged(_ notification: Notification) {
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
}

extension Jo_FullPostVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor == UIColor.lightGray) {
            textView.text = ""
            textView.textColor = UIColor.black.withAlphaComponent(0.75)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if (!textView.hasText) {
            textView.text = placehoalderText
            textView.textColor = UIColor.lightGray
        }
    }
}
