//
//  Jo_PostVC.swift
//  join
//
//  Created by 連亮涵 on 2020/6/30.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Firebase
import FirebaseStorage

class Jo_PostVC: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UIToolbarDelegate, TLPhotosPickerViewControllerDelegate {
    
    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var v_mid: UIView!
    @IBOutlet weak var v_line: UIView!
    @IBOutlet weak var v_address: UIView!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var img_photo: UIImageView!
    @IBOutlet weak var img_Plus: UIImageView!
    @IBOutlet weak var txt_theme: UITextView!
    @IBOutlet weak var txt_startTime: PickerTextField!
    @IBOutlet weak var txt_cutOffTime: PickerTextField!
    @IBOutlet weak var txt_Attendance: PickerTextField!
    @IBOutlet weak var txt_Budget_Type: PickerTextField!
    @IBOutlet weak var txt_Budget: PickerTextField!
    @IBOutlet weak var txt_party_Info: UITextView!
    @IBOutlet weak var lbl_partyInfo: UILabel!
    @IBOutlet weak var btn_address: UIButton!
    
    var TLimgPicker = TLPhotosPickerViewController()
    var TLConfig = TLPhotosPickerConfigure()
    let dateformatter = DateFormatter()
    let attendPicker = UIPickerView()
    let budgetPicker = UIPickerView()
    let budgetTypPicker = UIPickerView()
    var tmp = Date()
    let today = NSDate()
    
    var fullPost = Party()
    var img_url = ""
    var attendanceID = ""
    var budgetID = ""
    var budgetTypeID = ""
    var adress = ""
    var city = ""
    var ptid = ""
    var placehoalderText = "注意：不可含有 揪in APP以外之報名連結與資訊（如：Google表單、LINE、FB、TG、電話...等)"
    
    var isUpdate = false
    var serverStartTime = ""
    var serverCutTime = ""

    var attendance_combine_Arr: [Combine] = []
    var budget_Type_combine_Arr: [Combine] = []
    var budget_combine_Arr: [Combine] = []
    
    var postTextHeight: CGFloat!
    var postInfoHight: CGFloat!
    var originMainHeight: CGFloat = 0
    var keyBoardHeight: CGFloat = 0
    var keyBoardShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        NotificationCenter.default.addObserver(self, selector: #selector(changeAdress), name: NSNotification.Name(rawValue: "changeAdress"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        view.addGestureRecognizer(tap)
        let Touch = UITapGestureRecognizer(target: self, action: #selector(choosePhoto(_:)))
        img_photo.addGestureRecognizer(Touch)
        //
        attendance_combine_Arr = combineArray(idArr: globalData.attendance_id_array, txtArr: globalData.attendance_array)
        budget_combine_Arr = combineArray(idArr: globalData.budget_id_array, txtArr: globalData.budget_array)
        budget_Type_combine_Arr = combineArray(idArr: globalData.budget_type_id_array, txtArr: globalData.budget_type_array)
        //
        presentationController?.delegate = self
        TLimgPicker.delegate = self
        TLimgPicker.configure.allowedVideo = false
        TLConfig.usedCameraButton = false
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.locale = Locale(identifier: "zh_CN")
        //
        txt_theme.tag = 1
        txt_theme.delegate = self
        txt_theme.textContainerInset = UIEdgeInsets(top: 16, left: 150, bottom: 8, right: 0)
        //
        btn_address.frame = CGRect(x: after(lbl_address) + 15, y: 0, width: view.frame.width - lbl_address.frame.width, height: v_address.frame.height)
        //
        txt_party_Info.delegate = self
        txt_party_Info.tag = 2
        txt_party_Info.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        txt_party_Info.text = placehoalderText
        txt_party_Info.textColor = UIColor.black.withAlphaComponent(0.4)
        //
        postInfoHight = txt_party_Info.frame.height
        postTextHeight = txt_theme.frame.height
        //
        txt_startTime.text = "請選擇"
        txt_cutOffTime.text = "請選擇"
        txt_Budget.text = "請選擇"
        txt_Attendance.text = "請選擇"
        txt_Budget_Type.text = "請選擇"
        //
        configure_ImageView()
        configure_dateTextField()
        configure_pickerTextField()
        checkUpdate()
        //
        sv_main.delegate = self
        sv_main.contentSize.height = txt_party_Info.frame.origin.y + txt_party_Info.frame.height
    }
    
    func configure_ImageView() {
        img_photo.layer.cornerRadius = img_photo.frame.height / 10
        img_photo.contentMode = .scaleAspectFill
        img_photo.layer.masksToBounds = true
        img_photo.layer.borderColor = Colors.themePurple.cgColor
        img_photo.layer.borderWidth = 1
        img_photo.isUserInteractionEnabled = true
    }
    
    func configure_dateTextField() {
        txt_startTime.delegate = self
        txt_cutOffTime.delegate = self
        txt_startTime.setInputPostJoDatePicker(target: self, selector: #selector(tapStart))
        txt_cutOffTime.setInputPostJoDatePicker(target: self, selector: #selector(tapCut))
    }
    
    func configure_pickerTextField() {
        setupPickerDelegates()
        txt_Attendance.setupTextFieldPicker(pv: attendPicker, target: self, toolbarAction: #selector(toolbar＿done))
        txt_Budget.setupTextFieldPicker(pv: budgetPicker, target: self, toolbarAction: #selector(toolbar＿done))
        txt_Budget_Type.setupTextFieldPicker(pv: budgetTypPicker, target: self, toolbarAction: #selector(toolbar＿done))
    }
    
    func setupPickerDelegates() {
        attendPicker.delegate = self
        attendPicker.dataSource = self
        budgetPicker.delegate = self
        budgetPicker.dataSource = self
        budgetTypPicker.delegate = self
        budgetTypPicker.dataSource = self
        attendPicker.tag = 1
        budgetPicker.tag = 2
        budgetTypPicker.tag = 3
    }
    
    func checkUpdate() {
        if isUpdate {
            navigationItem.title = "修改聚會"
            img_Plus.isHidden = true
            DownloadImage(view: img_photo, img: fullPost.img_url, id: "ptid:" + ptid, placeholder: nil)
            txt_theme.text = fullPost.title
            txt_startTime.text = changeformat2(string: fullPost.starttime, part: "all")
            txt_cutOffTime.text = changeformat2(string: fullPost.cutofftime, part: "all")
            adress = fullPost.address
            btn_address.setTitle(fullPost.address, for: .normal)
            txt_Attendance.text = fullPost.attendance
            txt_Budget.text = fullPost.budget
            txt_Budget_Type.text = fullPost.budgettype
            txt_party_Info.text = fullPost.party_info
            txt_party_Info.textColor = UIColor.black.withAlphaComponent(0.75)
            tmp = dateformatter.date(from:fullPost.starttime)!
        }
    }
    
    func callUpFilesService() {
        var urlLink : String = ""
        var data: String = ""

        if serverStartTime == "" {
            serverStartTime = self.fullPost.starttime
        }
        if serverCutTime == "" {
            serverCutTime = self.fullPost.cutofftime
        }
        if self.isUpdate {
            urlLink = globalData.UpdatePartyUrl
            data = "token=\(globalData.token)&ptid=\(self.ptid)&img_url=\(img_url)&title=\(txt_theme.text!)&starttime=\(serverStartTime)&cutofftime=\(serverCutTime)&address=\(adress)&attendance=\(attendanceID)&budget_type=\(budgetTypeID)&budget=\(budgetID)&party_info=\(txt_party_Info.text!)&location=\(city)&source=\("ios")"
        } else {
            urlLink = globalData.NewPartyUrl
            data = "token=\(globalData.token)&img_url=\(img_url)&title=\(txt_theme.text!)&starttime=\(serverStartTime)&cutofftime=\(serverCutTime)&address=\(adress)&attendance=\(attendanceID)&budget_type=\(budgetTypeID)&budget=\(budgetID)&party_info=\(txt_party_Info.text!)&location=\(city)&source=\("ios")"
        }

        let request = createHttpRequest(Url: urlLink, HttpType: "POST", Data: data)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                //關閉發文提示
                DispatchQueue.main.async {
                    dismissAlert(selfVC: self)
                }
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    //關閉發文提示
                    dismissAlert(selfVC: self) {
                        if responseJSON["code"] as! Int == 0
                        {
                            self.txt_theme.text = "請選擇"
                            self.txt_party_Info.text = "請選擇"
                            self.endEdit()
                            if self.isUpdate {
                                shortInfoMsg(msg: "活動修改完成!", vc: self,sec: 2) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                self.dismiss(animated: true) {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "goSuccessPartyVC"), object: nil)
                                }
                            }
                        }
                        else if responseJSON["code"] as! Int == 138
                        {
                            shortInfoMsg(msg: "活動時間最早需在2小時後", vc: self, sec: 2)
                        }
                        else if responseJSON["code"] as! Int == 137
                        {
                            shortInfoMsg(msg: "報名截止日需在活動時間之前", vc: self, sec: 2)
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
        }
        task.resume()
    }
    
    func uploadImgs(img:UIImage)
    {
        let DateStr = getTPETime(format: "yyyyMMdd")
        let DateTimeStr = getTPETime(format: "yyyyMMddHHmmss")
        let fileName = globalData.token + DateTimeStr
        
        let storageRef = Storage.storage().reference().child("PartyImage/" + DateStr).child("\(fileName).jpg")
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
                    self.img_url  = String(url.absoluteString[ ..<endIndex])
                    self.callUpFilesService()
                }
            }
        }
    }
    
    //MARK: - TextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        switch textView.tag {
        case 1:
            return numberOfChars < 40
        case 2:
            return numberOfChars < 5000
        default:
            return numberOfChars < 0
        }
    }
 
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 1:
            if (txt_theme.contentSize.height > postTextHeight || txt_theme.frame.height > postTextHeight) {
                //字文字超出邊界時加大高度
                txt_theme.frame.size = txt_theme.contentSize
                txt_theme.scrollRangeToVisible(NSMakeRange(0, 0))

                //調整下方的位置
                v_line.frame = CGRect(x: v_line.frame.origin.x, y: below(txt_theme), width: v_line.frame.width, height: v_line.frame.height)
                v_address.frame = CGRect(x: v_address.frame.origin.x, y:below(v_line), width: v_address.frame.width, height: v_address.frame.height)
                v_mid.frame = CGRect(x: v_mid.frame.origin.x, y: below(v_address) + 20, width: v_mid.frame.width, height:v_mid.frame.height)
                lbl_partyInfo.frame = CGRect(x: lbl_partyInfo.frame.origin.x, y: below(v_mid) + 20, width: lbl_partyInfo.frame.width, height:lbl_partyInfo.frame.height)
                txt_party_Info.frame = CGRect(x: txt_party_Info.frame.origin.x, y: below(lbl_partyInfo) + 8, width: txt_party_Info.frame.width, height:txt_party_Info.frame.height)
                sv_main.contentSize.height =  txt_party_Info.frame.origin.y + txt_party_Info.frame.height
            }
        case 2:
            if  txt_party_Info.contentSize.height > postInfoHight {
                //字文字超出邊界時加大高度
                let diff = txt_party_Info.contentSize.height - txt_party_Info.frame.size.height
                txt_party_Info.frame.size.height = txt_party_Info.contentSize.height
                sv_main.contentSize.height =  txt_party_Info.frame.origin.y + txt_party_Info.frame.height
                sv_main.contentOffset.y += diff
            } else {
                txt_party_Info.contentSize.height = postInfoHight
            }
        default:
            break
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView.tag {
        case 2:
            let bottomOffset = CGPoint(x: 0, y: sv_main.contentSize.height - sv_main.bounds.size.height)
            sv_main.setContentOffset(bottomOffset, animated: true)
            //開始編輯後去除placeholder
            if (textView.textColor == UIColor.black.withAlphaComponent(0.4)) {
                textView.text = ""
                textView.textColor = UIColor.black.withAlphaComponent(0.75)
            }
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 2:
            //結束編輯後依字數生成placeholder
            if  !textView.hasText {
                textView.text = placehoalderText
                textView.textColor = UIColor.black.withAlphaComponent(0.4)
            }
        default:
            break
        }
    }
    
    func checkWihchEmpty() {
        if img_photo.image == nil { shortInfoMsg(msg: "請上傳一張活動照片。", vc: self, sec: 2); return }
        if txt_theme.text == "" { shortInfoMsg(msg: "請填選活動主題。", vc: self, sec: 2); return }
        if txt_startTime.text == "請選擇" { shortInfoMsg(msg: "請填選活動開始時間。", vc: self, sec: 2); return }
        if txt_cutOffTime.text == "請選擇" { shortInfoMsg(msg: "請填選報名截止時間。", vc: self, sec: 2); return }
        if txt_Attendance.text == "請選擇" { shortInfoMsg(msg: "請填選活動人數。", vc: self, sec: 2); return }
        if txt_Budget.text == "請選擇" { shortInfoMsg(msg: "請填選活動預算。", vc: self, sec: 2); return }
        if txt_Budget_Type.text == "請選擇" { shortInfoMsg(msg: "請填選活動費用。", vc: self, sec: 2); return }
        if txt_party_Info.text == placehoalderText { shortInfoMsg(msg: "請填選活動描述。", vc: self, sec: 2); return }
        if adress == "" { shortInfoMsg(msg: "請填選活動地址。", vc: self, sec: 2); return}
    }
        
    //MARK: - PhotoPicker
    
    func photoPickerDidCancel() {
        img_Plus.isHidden = false
        img_photo.layer.borderColor = Colors.themePurple.cgColor
        img_photo.layer.borderWidth = 1
    }
            
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        for asset in TLimgPicker.selectedAssets {
            img_photo.image = getImg(asset: asset.phAsset!)!
        }
    }
    
    @objc func choosePhoto(_ sender: UIButton) {
        img_photo.layer.borderWidth = 0
        img_Plus.isHidden = true
        TLimgPicker.configure = TLConfig
        TLimgPicker.configure.maxSelectedAssets = 1
        TLimgPicker.selectedAssets.removeAll()
        present(TLimgPicker, animated: true, completion: nil)
        TLimgPicker.collectionView.reloadData()
    }
    
    @objc func tapStart() {
        if let datePicker = self.txt_startTime.inputView as? UIDatePicker {
            let tmp2 = Calendar.current.date(byAdding:. hour, value: +2, to: Date())
            let interval = tmp2!.timeIntervalSince(datePicker.date)
            if interval > 7200 {
                shortInfoMsg(msg: "聚會時間需距離現在2小時。", vc: self, sec: 2)
            } else {
                serverStartTime = dateformatter.string(from: datePicker.date)
                self.txt_startTime.text = changeformat2(string: serverStartTime, part: "all")
                tmp = datePicker.date
                self.txt_startTime.resignFirstResponder()
            }
        }
    }
    
    @objc func tapCut() {
        if let datePicker = self.txt_cutOffTime.inputView as? UIDatePicker {
            if txt_startTime.text == "請選擇" {
                shortInfoMsg(msg: "請先選擇聚會時間。", vc: self, sec: 2)
            } else {
                let interval = tmp.timeIntervalSince(datePicker.date)
                if interval < 0 {
                    shortInfoMsg(msg: "選擇時間必需於聚會時間之前。", vc: self, sec: 2)
                } else {
                    serverCutTime = dateformatter.string(from: datePicker.date)
                    self.txt_cutOffTime.text = changeformat2(string: serverCutTime, part: "all")
                    self.txt_cutOffTime.resignFirstResponder()
                }
            }
        }
    }
    
    @objc func changeAdress() {
        adress = globalData.tmpAdress
        city = globalData.tmpCity
        btn_address.setTitle(adress, for: .normal)
        globalData.tmpCity = ""
        globalData.tmpAdress = ""
    }
    
    @objc func toolbar＿done() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = (notification as Notification).userInfo, let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyBoardHeight = value.cgRectValue.height
        if !keyBoardShow {
            sv_main.frame.size.height -= keyBoardHeight
            keyBoardShow = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if keyBoardShow {
            sv_main.frame.size.height += keyBoardHeight
            keyBoardShow = false
        }
    }
    
    @objc func KeyboardHeightChanged(_ notification: Notification){
        let changedKeyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        if keyBoardShow == true && keyBoardHeight != changedKeyboardSize.height {
            if keyBoardHeight > changedKeyboardSize.height{
                let keyboardDifference: CGFloat = keyBoardHeight - changedKeyboardSize.height
                sv_main.frame.size.height += keyboardDifference
            }
            keyBoardHeight = changedKeyboardSize.height
        }
    }
    
    @IBAction func submit() {
        txt_theme.resignFirstResponder()
        txt_party_Info.resignFirstResponder()
        
        if img_photo.image == nil || txt_theme.text == "" || txt_startTime.text == "請選擇" || txt_cutOffTime.text == "請選擇" || txt_Attendance.text == "請選擇"  || txt_Budget.text == "請選擇" || txt_Budget_Type.text == "請選擇" || txt_party_Info.text == placehoalderText || adress == "" {
            checkWihchEmpty()
            return
        } else {
            let alert = GetLoadingView(msg: "活動送出中 請稍候...")
            present(alert, animated: true, completion: nil)
        }

        if img_photo.image != nil {
            uploadImgs(img: img_photo.image!)
        }
    }
    
    @IBAction func goMap(_ sender: Any) {
        self.navigationItem.title = ""
        let vc = storyboard?.instantiateViewController(withIdentifier: "Map") as! MapVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        if isUpdate {
            self.dismiss(animated: true, completion: nil)
        } else {
            Alert.cancelPostPartyAlert(vc: self)
        }
    }
}

extension Jo_PostVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return attendance_combine_Arr.count
        case 2:
            return budget_combine_Arr.count
        case 3:
            return budget_Type_combine_Arr.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return attendance_combine_Arr[row].txt
        case 2:
            return budget_combine_Arr[row].txt
        case 3:
            return budget_Type_combine_Arr[row].txt
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            txt_Attendance.text = attendance_combine_Arr[row].txt
            attendanceID = attendance_combine_Arr[row].id
            if globalData.isVip == "N" {
                if txt_Attendance.text == attendance_combine_Arr[1].txt {
                    txt_Attendance.text = "請選擇"
                    Alert.buyVIPAlert(vc: self, title: "發佈雙人浪漫約會", msg: "一般會員無法發佈雙人約會，升級鑽石VIP，讓你有機會遇見對的人。", from: "發佈雙人約會")
                }
            }
        case 2:
            txt_Budget.text = budget_combine_Arr[row].txt
            budgetID = budget_combine_Arr[row].id
        case 3:
            txt_Budget_Type.text = budget_Type_combine_Arr[row].txt
            budgetTypeID = budget_Type_combine_Arr[row].id
        default:
            break
        }
    }
}

extension Jo_PostVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    //下拉關閉取消時，下拉手勢觸發
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        Alert.cancelPostPartyAlert(vc: self)
    }
}
