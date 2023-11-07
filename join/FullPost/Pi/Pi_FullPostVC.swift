//
//  Pi_FullPostVC.swift
//  join
//
//  Created by 連亮涵 on 2020/6/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import TLPhotoPicker
import MJRefresh

class Pi_FullPostVC: UIViewController,UIGestureRecognizerDelegate,TLPhotosPickerViewControllerDelegate {
   
    @IBOutlet weak var sv_post: UIScrollView!
    @IBOutlet weak var v_Post: UIView!
    @IBOutlet weak var v_Comment: UIView!
    @IBOutlet weak var btn_back: UIBarButtonItem!
    @IBOutlet weak var v_Input: UIView!
    @IBOutlet weak var txt_Input: UITextView!
    @IBOutlet weak var btn_Send: UIButton!
    @IBOutlet weak var btn_pic: UIButton!
    @IBOutlet weak var btn_Report: UIBarButtonItem!
    
    var TLConfig = TLPhotosPickerConfigure()
    var TLimgPicker = TLPhotosPickerViewController()
    let rc_head = MJRefreshNormalHeader()
    var currentTextView: UITextView?
    
    var commentsHeight: CGFloat = 0
    var keyBoardHeight: CGFloat = 0
    var rect: CGRect?
    
    var keyBoardShow = false
    
    var fullPost = Post()
    var replyCmt: [Combine] = []
    var pid = ""
    var uid = ""
    
    //第二層留言相關
    var subComtText = false
    var fatherCmtid = ""
    
    //滾至留言相關
    var scrolltoComt = false
    var scrollCmtid = ""
    var scroll_y: CGFloat = 0
    
    let placehoalderText = "輸入留言..."
    var commentsCount = 0
    
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
        sv_post.mj_header = rc_head
        rect = view.bounds
        //取得postID
        if let navi = self.navigationController as? Pi_FullPostNavi {
            pid = navi.pid
            uid = navi.uid
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
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.postTouched(_:)))
        sv_post.addGestureRecognizer(tap)

        rect = view.bounds
        if #available(iOS 11.0, *) {
            sv_post.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: sv_post.superview?.leadingAnchor, bottom: v_Input.topAnchor, trailing: sv_post.superview?.trailingAnchor)
        } else {
            sv_post.anchor(top: sv_post.superview?.topAnchor, leading: sv_post.superview?.leadingAnchor, bottom: v_Input.topAnchor, trailing: sv_post.superview?.trailingAnchor)
        }
        callPostService(moveToBottom: false)
    }
    
    func callPostService(moveToBottom:Bool)
    {
        if pid != ""
        {
            let request = createHttpRequest(Url: globalData.OpenHpItemUrl, HttpType: "POST", Data: "token=\(globalData.token)&type=\("隨手拍")&pid=\(pid)")
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
                            let po = responseJSON["post"] as! [[String: Any]]
                            parsePosts(post: self.fullPost, po: po[0])
                            //將貼文設置在畫面上
                            self.setPost()
                            
                            self.clearComments()
                            for cos in responseJSON["comts"] as! [[String: Any]] {
                                let tmpComts = Comts()
                                parseComts(comts:tmpComts,cos:cos)
                                //設置留言
                                self.setComments(cos: tmpComts)
                            }
                            self.resetHeights()
                            
                            if moveToBottom {
                                self.sv_post.setContentOffset(CGPoint(x: 0,y: max( self.sv_post.contentSize.height - self.sv_post.frame.height,0)), animated: true)
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
    
    func callBlockPostService()
    {
        let request = createHttpRequest(Url: globalData.BlockPostUrl, HttpType: "POST", Data: "token=\(globalData.token)&pid=\(pid)")
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        self.backtoHome(0)
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.present(vc, animated: true, completion: nil)
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
    
    func reportPost(accuse_reason: String) {
        NetworkManager.shared.callReportService(target: "post", id: self.uid, accuse_reason: accuse_reason) { (code, msg) in
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
    
    func callCommentService(comtType: Int) {
        var urlLink : String = ""
        var data: String = ""
        
        let newText = txt_Input.text.replacingOccurrences(of: "+", with: "%2B")
        //let atUid = atUidArray.joined(separator: ",")
        
        if comtType == 0 {
            urlLink = globalData.NewPComtfUrl
            data = "token=\(globalData.token)&pid=\(pid)&text=\(newText)"
        } else if comtType == 1 {
            urlLink = globalData.NewPComtsUrl
            data = "token=\(globalData.token)&cmtid=\(fatherCmtid)&text=\(newText)"
        }
        
        let request = createHttpRequest(Url: urlLink , HttpType: "POST", Data: data)

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
                        self.replyCmt.removeAll()
                        self.textViewDidEndEditing(self.txt_Input)
                        
                        if comtType == 0 {
                            self.callPostService(moveToBottom: true)
                        } else if comtType == 1 {
                            self.subComtText = false
                            self.callPostService(moveToBottom: false)
                        }
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
    
    func setPost()
    {
        //設置貼文
        let fullPostView = Pi_FullPostView()
        fullPostView.setPostData(username: fullPost.username, user_img: fullPost.user_img, posttime: fullPost.posttime, text: fullPost.text, img_url: fullPost.img_url, gp: fullPost.gp , comt_cnt: fullPost.comt_cnt, width:v_Post.frame.width, pid: self.pid, uid: self.uid, isGood: fullPost.isGd )
        fullPostView.parentVC = self
        self.v_Post.addSubview(fullPostView)
        self.v_Post.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: fullPostView.frame.height)
    }
    
    func setComments(cos: Comts) {
        //設置留言
        commentsCount += 1
        
        let commentsView = CommentView()
        commentsView.initwithComments(username:cos.username, user_img:cos.user_img, text:cos.text, createtime:cos.createtime, comtArr: cos.comtArr, cmtid: cos.cmtid, uid: cos.uid, y:self.commentsHeight, width:self.v_Comment.frame.width, pid: pid, ptid: "", from: "pi")
        v_Comment.addSubview(commentsView)
        
        commentsHeight += commentsView.frame.height
        
        if  scrollCmtid == cos.cmtid {
            scroll_y = commentsHeight
        }
    }
    
    func resetHeights() {
        //載入完成後調整高度
        self.v_Comment.frame = CGRect(x: 0, y: self.v_Post.frame.height, width: self.view.frame.width, height: self.commentsHeight)
        self.sv_post.contentSize = CGSize(width: self.view.frame.width, height: self.v_Post.frame.height + self.commentsHeight)
        
        if scrolltoComt {
            sv_post.setContentOffset(CGPoint(x: 0,y: max((v_Comment.frame.origin.y + scroll_y) - sv_post.frame.height  ,0)), animated: true)
            scrolltoComt = false
        }
    }

    func clearComments() {
        for v in self.v_Comment.subviews {
            v.removeFromSuperview()
        }
        commentsCount = 0
        commentsHeight = 0
    }
    
    @IBAction func backtoHome(_ sender: Any)
    {
        let count = self.navigationController?.viewControllers.count
        if count! > 1 {
            self.navigationController!.popViewController(animated: true)
        } else {
            self.navigationController!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func report(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportHandler = { (action:UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "檢舉貼文", message: nil, preferredStyle: .alert)
            let one = UIAlertAction(title: "這是垃圾訊息", style: .default){ (_) in
                self.reportPost(accuse_reason: "001")
            }
            let two = UIAlertAction(title: "含有敏感圖片內容", style: .default){ (_) in
                self.reportPost(accuse_reason: "002")
            }
            let three = UIAlertAction(title: "含有謾罵或有害內容", style: .default){ (_) in
                self.reportPost(accuse_reason: "003")
            }
            let four = UIAlertAction(title: "其他", style: .default){ (_) in
                self.reportPost(accuse_reason: "004")
            }
            [one,two,three,four].forEach{ alertMessage.addAction($0) }
            alertMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alertMessage,animated: true, completion: nil)
        }
        
        let blockHandler = { (action:UIAlertAction!) -> Void in
            let alertController = UIAlertController(title: "是否確定隱藏該貼文？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive){(UIAlertAction) in
                self.callBlockPostService()
            }
            alertController.addAction(okAction)
            alertController.addAction(UIAlertAction(title:"取消",style: .cancel))
            self.present(alertController,animated: true, completion: nil)
        }
        
        let editHandler = { (action:UIAlertAction!) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PiPostVC") as! PostVC
            vc.isupdate = true
            vc.fullPost = self.fullPost
            vc.pid = self.pid
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if fullPost.isMyself == "1" {
            optionMenu.addAction(UIAlertAction(title: "編輯貼文", style: .default, handler: editHandler))
        }
        optionMenu.addAction(UIAlertAction(title: "檢舉此貼文", style: .destructive, handler: reportHandler))
        optionMenu.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        optionMenu.addAction(UIAlertAction(title: "隱藏此貼文", style: .destructive, handler: blockHandler))
        present(optionMenu,animated: true, completion: nil)
    }
    
    @IBAction func SendComment(_ sender: Any ) {
        txt_Input.resignFirstResponder()
        if txt_Input.textColor == UIColor.black.withAlphaComponent(0.75) && txt_Input.text!.count > 0 {
            self.btn_Send.isEnabled = false
            if subComtText {
                self.btn_Send.isEnabled = false
                callCommentService(comtType: 1)
            } else {
                self.btn_Send.isEnabled = false
                callCommentService(comtType: 0)
            }
        } else {
            shortInfoMsg(msg: "請輸入留言內容", vc: self, sec: 2)
        }
    }
    
    @objc func postTouched(_ sender:UIGestureRecognizer){
        txt_Input.resignFirstResponder()
    }
    
    @objc func refresh() {
        callPostService(moveToBottom: false)
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
}

extension Pi_FullPostVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentTextView = textView
        //開始編輯後去除placeholder
        if  textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black.withAlphaComponent(0.75)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //結束編輯後依字數生成placeholder
        if  !textView.hasText {
            textView.text = placehoalderText
            textView.textColor = UIColor.lightGray
        }
    }
}
