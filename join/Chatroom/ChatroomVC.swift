//
//  ChatroomVC.swift
//  join
//
//  Created by ChrisLien on 2020/9/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import TLPhotoPicker

class ChatroomVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,TLPhotosPickerViewControllerDelegate {
    
    @IBOutlet weak var btn_back: UIBarButtonItem!
    @IBOutlet weak var v_input: UIView!
    @IBOutlet weak var txt_input: UITextView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var btn_pic: UIButton!
    @IBOutlet weak var btn_report: UIBarButtonItem!
        
    let v_inform = UIView()
    
    let img_friendIcon: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 75
        return iv
    }()
    
    let lbl_informTime: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18)
        lbl.textAlignment = .center
        lbl.textColor = Colors.rgb91Gray
        return lbl
    }()
    
    let lbl_informTxt: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 22)
        lbl.textAlignment = .center
        lbl.textColor =  Colors.rgb41Black
        return lbl
    }()
    
    var currentTextView: UITextView?
    let imgPicker = UIImagePickerController()
    var TLConfig = TLPhotosPickerConfigure()
    var TLimgPicker = TLPhotosPickerViewController()
    var ref: DatabaseReference!
    
    var msgArray:[Msg] = []
    var friend_uid = ""
    var friend_shortid = ""
    var chtid = ""
    var username = ""
    var img_url = ""
    var from = ""
    var hasFirstMsg = false
    let placehoalderText = "輸入文字..."
    var keyBoardHeight : CGFloat = 0
    var rect: CGRect?
    var keyBoardShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        ref = Database.database().reference()
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if from != "UserProfileVC" { hideMainBar() }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(txtEndEdit))
        view.addGestureRecognizer(tap)
        
        imgPicker.delegate = self
        TLimgPicker.delegate = self
        TLConfig.usedCameraButton = false
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
        
        txt_input.delegate = self
        txt_input.text = placehoalderText
        txt_input.textContainerInset = UIEdgeInsets(top: 8, left: 35, bottom: 0, right: 35)
        txt_input.textColor = UIColor.lightGray
        txt_input.layer.borderWidth = 1
        txt_input.layer.borderColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        txt_input.layer.cornerRadius = txt_input.frame.height/2
        
        btn_pic.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_pic.frame.height/2)
        btn_pic.layer.cornerRadius = btn_pic.frame.height/2
        btn_pic.tintColor = .white
        btn_pic.bringSubviewToFront(btn_pic.imageView!)
       
        rect = view.bounds
        title = username
        //if !hasFirstMsg { getChatroomCreateTime() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.txt_input.resignFirstResponder()
        if from != "UserProfileVC" { hideMainBar() }
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue" {
            let containerVC = segue.destination as! ChatroomViewVC
            containerVC.chtid = self.chtid
            containerVC.friend_shortid = self.friend_shortid
            containerVC.username = self.username
            containerVC.friend_uid = self.friend_uid
            containerVC.img_url = self.img_url
        }
    }
    
    func getChatroomCreateTime() {
        NetworkManager.shared.callGetChatroomCreateTimeService(chtid: chtid) { (code, createTimeSpan) in
            if code == 0 { self.configure_v_infrom(createTimeSpan: createTimeSpan!) }
        }
    }
    
    func configure_v_infrom(createTimeSpan: String) {
        setupAnchors()
        lbl_informTxt.text = "你已與 \(username) 配對"
        DownloadImage(view: img_friendIcon, img: img_url, id: "uid" + friend_uid, placeholder: UIImage(named: "user.png"))
        lbl_informTime.text = createTimeSpan
    }
    
    func setupAnchors() {
        view.addSubview(v_inform)
        [lbl_informTxt, lbl_informTime, img_friendIcon].forEach { v_inform.addSubview($0) }
        v_inform.centerAnchor(centerX: view.safeAreaLayoutGuide.centerXAnchor, centerY: view.safeAreaLayoutGuide.centerYAnchor, size: CGSize(width: 230, height: 250))
        lbl_informTxt.anchor(top: v_inform.topAnchor, leading: v_inform.leadingAnchor, bottom: nil, trailing: v_inform.trailingAnchor, size: CGSize(width: 0, height: 30))
        lbl_informTime.anchor(top: lbl_informTxt.bottomAnchor, leading: v_inform.leadingAnchor, bottom: nil, trailing: v_inform.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0),size: CGSize(width: 0, height: 25))
        img_friendIcon.anchor(top: lbl_informTime.bottomAnchor, leading: v_inform.leadingAnchor, bottom: nil, trailing: v_inform.trailingAnchor, padding: .init(top: 23, left: 40, bottom: 0, right: 40),size: CGSize(width: 0, height: 150))
           
    }
    
    func sendMsg() {
        let newMsgChild = Database.database().reference().child("chatroom").child(chtid).childByAutoId()
        let timestamp = Int64(NSDate().timeIntervalSince1970*1000)
        newMsgChild.setValue(["id": globalData.shortid,
                              "isread": [globalData.shortid],
                              "msg": txt_input.text!,
                              "time": timestamp,
                              "type": "text"])
        callSendMsg()
        txt_input.text = ""
    }
    
    func callSendMsg() {
        NetworkManager.shared.callSendMsgService(recieveuid: friend_uid, message: txt_input.text!) { (code, msg) in
            switch code {
            case 0:
                print("sended")
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func callSendImg() {
        NetworkManager.shared.callSendImgeService(recieveuid: friend_uid) { (code, msg) in
            switch code {
            case 0:
                print("sended")
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
            
        }
    }
    
    func reportUser(accuse_reason: String) {
        NetworkManager.shared.callReportService(target: "user", id: friend_uid, accuse_reason: accuse_reason) { (code, msg) in
            switch code {
            case 0:
                Alert.basicActionAlert(vc: self, title: "抱歉，造成您的不悅", message: "我們已經收到您的檢舉通知，客服人員會盡快處理。", okBtnTitle: "確定", twoBtn: false) { (_) in
                    self.back(0)
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
    
    func blockUser() {
        NetworkManager.shared.callBlockUserService(uid: self.friend_uid) { (code, msg) in
            switch code {
            case 0:
                self.back(0)
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 128:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                vc.reason = msg!
                self.present(vc, animated: true, completion: nil)
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func uploadImgs(img:UIImage)
    {
        let DateTimeStr = getTPETime(format: "yyyyMMddHHmmss")
        let fileName = DateTimeStr
        let storageRef = Storage.storage().reference().child("ChatRoom/").child(self.chtid).child("\(fileName).jpg")
        if let uploadData = img.jpegData(compressionQuality: 0.8)
        {
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            // 這行就是 FirebaseStorage 關鍵的存取方法。
            _ = storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    //關閉發文提示
                    dismissAlert(selfVC: self)
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                storageRef.downloadURL() { url, error in
                    guard let url = url, error == nil else
                    {
                        ShowErrMsg(code: 0,msg: "圖片上傳失敗",vc: self)
                        return
                    }
                    let endIndex = url.absoluteString.range(of: "&token=")?.lowerBound ?? url.absoluteString.endIndex
                    let sending_img = String(url.absoluteString[ ..<endIndex])
                    
                    let newMsgChild = Database.database().reference().child("chatroom").child(self.chtid).childByAutoId()
                    let timestamp = Int64(NSDate().timeIntervalSince1970*1000)
                    newMsgChild.setValue(["id": globalData.shortid,
                                          "isread": [globalData.shortid],
                                          "msg": sending_img,
                                          "time": timestamp,
                                          "type": "img"])
                    self.callSendImg()
                }
            }
        }
    }
    
    func photoPickerDidCancel() {
    }
            
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        for asset in TLimgPicker.selectedAssets {
            let img_Photo = getImg(asset: asset.phAsset!)!
            uploadImgs(img: img_Photo)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 取得照片
        let image = info[.originalImage] as! UIImage
        uploadImgs(img: image)
        //取得照片後將imagePickercontroller dismiss
        picker.dismiss(animated: true, completion: nil)
        hideMainBar()
    }
    
    
    @IBAction func report(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let profileHandler = { (action:UIAlertAction!) -> Void in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.uid = self.friend_uid
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let reportHandler = { (action:UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "檢舉用戶", message: nil, preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "訊息騷擾", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "001")
            }))
            alertMessage.addAction(UIAlertAction(title: "照片不雅", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "002")
            }))
            alertMessage.addAction(UIAlertAction(title: "詐騙行為", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "003")
            }))
            alertMessage.addAction(UIAlertAction(title: "其他", style: .destructive, handler: {(action:UIAlertAction!) -> Void in
                self.reportUser(accuse_reason: "004")
            }))
            alertMessage.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alertMessage,animated: true, completion: nil)
        }
        
        let blockHandler = { (action:UIAlertAction!) -> Void in
            let alertController = UIAlertController(title: "是否確定封鎖該用戶？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive){(UIAlertAction) in
                self.blockUser()
            }
             alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title:"取消",style: .cancel)
            alertController.addAction(cancelAction)
            self.present(alertController,animated: true, completion: nil)
        }

        let profileAction = UIAlertAction(title: "個人檔案", style: .default, handler: profileHandler)
        let reportAction = UIAlertAction(title: "檢舉用戶", style: .destructive, handler: reportHandler)
        let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive, handler: blockHandler)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        [profileAction,reportAction,blockAction,cancelAction].forEach { optionMenu.addAction($0) }
        present(optionMenu,animated: true, completion: nil)
    }
    
    @IBAction func sendPicture(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraHandler = { (action:UIAlertAction!) -> Void in
            self.imgPicker.sourceType = .camera
            self.imgPicker.allowsEditing = true
            self.present(self.imgPicker, animated: true)
        }
        let photoHandler = { (action:UIAlertAction!) -> Void in
            self.TLimgPicker.configure = self.TLConfig
            self.TLimgPicker.configure.allowedVideo = false
            self.TLimgPicker.configure.maxSelectedAssets = 1
            self.TLimgPicker.selectedAssets.removeAll()
            self.present(self.TLimgPicker, animated: true, completion: nil)
            self.TLimgPicker.collectionView.reloadData()
        }
        let reportAction = UIAlertAction(title: "拍一張照", style: .default, handler: cameraHandler)
        let blockAction = UIAlertAction(title: "選一張照片", style: .default, handler: photoHandler)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(blockAction)
        present(optionMenu,animated: true, completion: nil)
    }
    
    @IBAction func SendComment(_ sender: Any ) {
        if txt_input.textColor == UIColor.black.withAlphaComponent(0.75) && txt_input.text!.count > 0 {
            sendMsg()
        } else {
            shortInfoMsg(msg: "請輸入留言內容", vc: self, sec: 2)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if let vc = self.findViewController() as? MainChatVC {
            vc.refresh()
        } 
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - @objc
    @objc func txtEndEdit() {
        //結束文字編輯
        txt_input.resignFirstResponder()
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
    
    @objc func _KeyboardHeightChanged(_ notification: Notification) {
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

extension ChatroomVC: UITextViewDelegate {
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
