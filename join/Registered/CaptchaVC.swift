//
//  PhoneAuthViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftyStoreKit
import SafariServices

class CaptchaViewController: UIViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var btn_resend: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var lbl_CountdownNum: UILabel!
    @IBOutlet weak var txt_TypeZone: UITextField!
    @IBOutlet weak var lbl_Countdown: UILabel!
    @IBOutlet weak var lbl_send_to_phone: UILabel!
    
    var verificationID: String = ""
    var timeStop : Int = 0
    var timer : Timer?
    var counter = 60
    var productId: String = ""
    var item_id: String = ""
    var transaction_id: String = ""
    var receiptInfo_array: [ReceiptInfo] = [ReceiptInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        lbl_Countdown.isHidden = true
        lbl_CountdownNum.isHidden = true
        //
        txt_TypeZone.delegate = self
        txt_TypeZone.placeholder = "請輸入6位數字 驗證碼"
        if #available(iOS 12.0, *) {
            txt_TypeZone.textContentType = .oneTimeCode
        }
        txt_TypeZone.setBottomBorder()
        //
        btn_next.backgroundColor = #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1)
        btn_next.isEnabled = false
        btn_next.layer.cornerRadius = btn_next.frame.height/2
        //
        btn_resend.alpha = 0.3
        btn_resend.layer.borderWidth = 1
        btn_resend.layer.borderColor = Colors.themePurple.cgColor
        btn_resend.layer.cornerRadius = btn_resend.frame.height/2
        btn_resend.isEnabled = false
        //
        lbl_Countdown.frame.origin.x = lbl_CountdownNum.frame.origin.x + lbl_CountdownNum.frame.width
        lbl_send_to_phone.text = "已傳送驗證碼至\(globalData.phonenum)"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        self.view.addGestureRecognizer(tap)
        //
        sendSMS()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result = false
        if let text = textField.text, let range = Range(range, in: text)
        {
            let newText = text.replacingCharacters(in: range, with: string)
            if newText.count < 6 {
                btn_next.backgroundColor = #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1)
                btn_next.isEnabled = false
                result = true
            } else if newText.count == 6 {
                btn_next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_next.frame.height/2)
                btn_next.isEnabled = true
                result = true
            } else {
                result = false
            }
        }
        return result
    }
    
    @IBAction func sendSMS() {
        let phoneNumber = globalData.phonenum
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                ShowErrMsg(code: 0, msg: "驗證碼發送失敗",vc: self)
                return
            }
            if verificationID != nil { self.verificationID = verificationID! }
            self.btn_resend.isEnabled = false
            self.btn_resend.alpha = 0.3
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func sendAuthCode(_ sender: Any) {
        if txt_TypeZone.text?.count == 6 {
            let credential = PhoneAuthProvider.provider().credential( withVerificationID: verificationID, verificationCode: txt_TypeZone.text!)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        default:
                            ShowErrMsg(code: 0, msg: "手機驗證失敗", vc: self)
                        }
                    }
                    return
                } else {
                    let ph = Auth.auth().currentUser?.phoneNumber ?? ""
                    if ph != "" {
                        shortInfoMsg(msg: "手機認證成功", vc: self,sec: 2) {
                            DispatchQueue.main.async {
                                self.callPhoneService()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.callPhoneService()
                        }
                    }
                }
            })
        } else {
            ShowErrMsg(code: 0, msg: "驗證碼格式錯誤",vc: self)
        }
    }
      
    func callPhoneService() {
        let request = createHttpRequest(Url: globalData.CheckPhoneUrl, HttpType: "POST", Data: "phonenum=\(globalData.serverPhonenum)&source=\("ios")&versionNo=\(globalData.appVersion)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,error == nil  else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let info = responseJSON["userInfo"] as? [String: Any]
                        {
                            parseLoginInfo(info)
                            self.transaction_id = getJsonValueString(info, key: "ios_transaction_id")
                            self.productId = getJsonValueString(info, key: "ios_product_id")
                            self.item_id = getJsonValueString(info, key: "ios_item_id")
                            globalData.last_productId = self.productId
                            DispatchQueue.main.async {
                                self.checkIfPurchaed()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismiss"), object: nil)
                            }
                        }
                    }
                    else if responseJSON["code"] as! Int == 146
                    {
                        let alertController = UIAlertController(title: "版本更新", message: "是否移動至App Store", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "確定", style: .default) { (UIAlertAction) in
                            let url = URL(string: "https://apps.apple.com/us/app/%E6%8F%AAin/id1516436708")!
                            let safariVC = SFSafariViewController(url: url)
                            safariVC.delegate = self
                            if #available(iOS 11.0, *) { safariVC.dismissButtonStyle = .close }
                            self.present(safariVC, animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ (UIAlertAction) in
                            exit(EXIT_SUCCESS)
                        }
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if responseJSON["code"] as! Int == 98
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! UserRegistrationVC
                        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func checkIfPurchaed() {
        if self.productId != "" {
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "45532437159b47cf8f1eeb2fe93feb84")
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    let productId = self.productId
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, //or .nonRenewing
                        productId: productId,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                        
                        for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                            self.receiptInfo_array.append(receipts)
                        }
                        let r = self.receiptInfo_array[0]
                        if self.transaction_id != r["transaction_id"] as? String ?? "" {
                            var latest_receipt = receipt["latest_receipt"] as! String
                            latest_receipt = latest_receipt.replacingOccurrences(of: "+", with: "%2B")
                                                           .replacingOccurrences(of: "\n", with: "")
                                                           .replacingOccurrences(of: "\r", with: "")
                            self.callGetDvipOrderNoService(productID: self.productId, item_id: self.item_id, receipt: latest_receipt)
                        }
                    case .expired(let expiryDate, let items):
                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                        
                        for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                            self.receiptInfo_array.append(receipts)
                        }
                        let r = self.receiptInfo_array[0]
                        if self.transaction_id != r["transaction_id"] as? String ?? "" {
                            var latest_receipt = receipt["latest_receipt"] as! String
                            latest_receipt = latest_receipt.replacingOccurrences(of: "+", with: "%2B")
                                                           .replacingOccurrences(of: "\n", with: "")
                                                           .replacingOccurrences(of: "\r", with: "")
                            self.callGetDvipOrderNoService(productID: self.productId, item_id: self.item_id, receipt: latest_receipt)
                        }
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                    }
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
        }
    }
    
    func callGetDvipOrderNoService(productID: String,item_id: String,receipt: String)
    {
        let request = createHttpRequest(Url: globalData.GetDvipOrderNoUrl, HttpType: "POST", Data: "token=\(globalData.token)&item_id=\(item_id)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                        if let order = responseJSON["orderNo"] as? String
                        {
                            self.calliosPayService(orderNo: order, receipt: receipt)
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
        
    func calliosPayService(orderNo: String,receipt: String)
    {
        let request = createHttpRequest(Url: globalData.iosPayUrl, HttpType: "POST", Data: "token=\(globalData.token)&isTest=\(globalData.testPay)&receipt=\(receipt)&orderNo=\(orderNo)")
       let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                        print("Success")
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
    
    @objc func countDown() {
        if lbl_CountdownNum.isHidden {
            lbl_Countdown.isHidden = false
            lbl_CountdownNum.isHidden = false
        } else if lbl_CountdownNum.text! != "0" {
            lbl_CountdownNum.text = String(Int(lbl_CountdownNum.text!)! - 1)
        }
        if lbl_CountdownNum.text! == "0" {
            timer?.invalidate()
            btn_resend.isEnabled = true
            btn_resend.alpha = 1
            lbl_CountdownNum.isHidden = true
            lbl_Countdown.isHidden = true
            lbl_CountdownNum.text = "60"
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
