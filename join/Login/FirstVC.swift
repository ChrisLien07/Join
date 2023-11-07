//
//  ViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftyStoreKit
import SafariServices

class FirstViewController: UIViewController, SFSafariViewControllerDelegate {

    var token: String = ""
    var productId: String = ""
    var item_id: String = ""
    var transaction_id: String = ""
    var receiptInfo_array: [ReceiptInfo] = [ReceiptInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(Login), name: Notifications.autoLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: NSNotification.Name(rawValue: "dismiss"), object: nil)
        setupGlobalHeights()
        checkAnnouncement()
    }
    
    func setupGlobalHeights() {
        globalData.imgHeight = (view.frame.width - 20) * 9 / 16
        globalData.coverHeight = (view.frame.width) * 3 / 5
    }
    
    func goToLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Login", sender:nil)
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true){
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar" ) as! MainTabBar
            self.present(VC, animated: true, completion: nil)
        }
    }
    
    @objc func Login() {
        if (Auth.auth().currentUser != nil) && (UserDefaults.standard.string(forKey: "Token") != nil) {
            globalData.loginReady = true
            if globalData.loginReady && globalData.fcmReady {
                self.callLoginService()
            }
        } else {
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
            goToLogin()
        }
    }
    
    @objc func callLoginService()
    {
        if let user = Auth.auth().currentUser
        {
            globalData.firebaseUid = user.uid
            let request = createHttpRequest(Url: globalData.UserLoginUrl, HttpType: "POST", Data: "firebaseid=\(globalData.firebaseUid)&source=\("ios")&fcmtoken=\(globalData.fcmToken)&versionNo=\(globalData.appVersion)")
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
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
                            let info = responseJSON["userInfo"] as! [String: Any]
                            parseLoginInfo(info)
                            self.transaction_id = getJsonValueString(info, key: "ios_transaction_id")
                            self.productId = getJsonValueString(info, key: "ios_product_id")
                            self.item_id = getJsonValueString(info, key: "ios_item_id")
                            globalData.last_productId = self.productId
                            self.checkIfPurchaed()
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar" ) as! MainTabBar
                            self.present(vc, animated: true, completion: nil)
                        }
                        else if responseJSON["code"] as! Int == 93
                        {
                            self.goToLogin()
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
                        else
                        {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func checkAnnouncement(){
        let url = URL(string: "https://www.bc9in.com/web/announcement.html")
        let task = URLSession.shared.dataTask(with: url!){ data, response, error in
            guard let data = data, error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["maintenance"] as! Int == 0 {
                    self.Login()
                } else {
                    DispatchQueue.main.async {
                        shortInfoMsg(msg: "目前揪in伺服器維護中，敬請見諒。", vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkIfPurchaed() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "45532437159b47cf8f1eeb2fe93feb84")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = self.productId
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, //or .nonRenewing
                    productId: self.productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    
                    for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                        self.receiptInfo_array.append(receipts)
                    }
                    let newestReceipt = self.receiptInfo_array[0]
                    if self.transaction_id != newestReceipt["transaction_id"] as? String ?? "" {
                        var latest_receipt = receipt["latest_receipt"] as! String
                        latest_receipt = latest_receipt.replacingOccurrences(of: "+", with: "%2B")
                                                       .replacingOccurrences(of: "\n", with: "")
                                                       .replacingOccurrences(of: "\r", with: "")
                        self.getDvipOrderNo(productID: self.productId, receipt: latest_receipt)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    
                    for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                        self.receiptInfo_array.append(receipts)
                    }
                    let newestReceipt = self.receiptInfo_array[0]
                    if self.transaction_id != newestReceipt["transaction_id"] as? String ?? "" {
                        var latest_receipt = receipt["latest_receipt"] as! String
                        latest_receipt = latest_receipt.replacingOccurrences(of: "+", with: "%2B")
                                                       .replacingOccurrences(of: "\n", with: "")
                                                       .replacingOccurrences(of: "\r", with: "")
                        self.getDvipOrderNo(productID: self.productId, receipt: latest_receipt)
                    }
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func getDvipOrderNo(productID: String, receipt: String) {
        NetworkManager.shared.callGetDvipOrderNoService { (code, orderNo, msg) in
            switch code {
            case 0:
                NetworkManager.shared.calliosPayService(orderNo: orderNo!, receipt: receipt) { (code, msg) in }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
            }
        }
    }
}
