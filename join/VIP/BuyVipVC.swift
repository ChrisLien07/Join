//
//  BuyVipVC.swift
//  join
//
//  Created by 連亮涵 on 2020/8/7.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import AppsFlyerLib
import SwiftyStoreKit
import UICollectionViewLeftAlignedLayout

class BuyVipVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var lbl_localizedTitle: UILabel!
    @IBOutlet weak var sv_banner: UIScrollView!
    @IBOutlet weak var pc_banner: UIPageControl!
    @IBOutlet weak var cv_buy: UICollectionView!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var btn_returnBuy: UIButton!
    @IBOutlet weak var txt_policy: UITextView!
    
    var timer = Timer()
    var productArray: [Product] = [Product]()
    var receiptInfo_array: [ReceiptInfo] = [ReceiptInfo]()
    
    var seleProductID = ""
    var seleItem_id = ""
    var from = ""
    
    var seleProduct: Product = Product()
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        cv_buy.delegate = self
        cv_buy.dataSource = self
        cv_buy.allowsMultipleSelection = false
        //
        btn_next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_next.frame.height/2)
        btn_next.layer.cornerRadius = btn_next.frame.height/2
        //
        configure_txt_policy()
        callInitPayService()
        collectionViewLayout()
        setScrollBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sv_main.contentSize.height = txt_policy.frame.origin.y + txt_policy.frame.height
    }
    
    fileprivate func setupPolicyAttributed() {
        let textRange1 = NSMakeRange(106, 5)
        let textRange2 = NSMakeRange(114, 4)
        let attributedString = NSMutableAttributedString(string: "透過點擊「繼續」，費用將自你的 iTunes帳戶扣款，你的訂購也將依同樣的套裝使用期限和相同的價格自動續訂，直到你於目前期限結束至少24小時到 iTunes 商店設定中取消為止。透過點擊「繼續」表示你同意我們的 隱私權政策 與 服務條款。")
        let serviceUrl_privacyUrl = URL(string: globalData.serviceUrl_privacyUrl)!
        attributedString.setAttributes([.link: serviceUrl_privacyUrl, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: textRange1)
        attributedString.setAttributes([.link: serviceUrl_privacyUrl, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: textRange2)
        txt_policy.attributedText = attributedString
    }
    
    fileprivate func configure_txt_policy()
    {
        setupPolicyAttributed()
        txt_policy.isUserInteractionEnabled = true
        txt_policy.isEditable = false
        txt_policy.font = .systemFont(ofSize:10)
        txt_policy.textAlignment = .center
        txt_policy.linkTextAttributes = [ .foregroundColor: UIColor.purple ]
    }
        
    fileprivate func setScrollBanner() {
        sv_banner.delegate = self
        sv_banner.tag = 1

        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(timerAction)), userInfo: nil, repeats: true)
        for banner in self.sv_banner.subviews {banner.removeFromSuperview()}
        var count : CGFloat = 0
        for banner in globalData.manVipPicArray
        {
            let tmpImg = UIImageView()
            tmpImg.frame = CGRect(x: (self.sv_banner.frame.width * count),y: 0,width: self.sv_banner.frame.width,height: self.sv_banner.frame.height)
            tmpImg.isUserInteractionEnabled = true
            tmpImg.layer.masksToBounds = true
            count += 1
            tmpImg.image = banner
            self.sv_banner.addSubview(tmpImg)
            self.sv_banner.contentSize.width = self.sv_banner.frame.width * count
        }
        self.pc_banner.currentPage = 0
        self.pc_banner.numberOfPages = globalData.manVipPicArray.count
    }
        
    func getInfo()
    {
        var productIDs = Set<String>()
        for pro in productArray
        {productIDs.insert(pro.productID)}
        if productIDs.count > 0
        {
            SwiftyStoreKit.retrieveProductsInfo(productIDs) { result in
                if let _ = result.retrievedProducts.first {
                    for pro in result.retrievedProducts {
                        for tmpPro in self.productArray {
                            if tmpPro.productID == pro.productIdentifier {
                                tmpPro.amount = pro.localizedPrice!
                            }
                        }
                    }
                    self.cv_buy.reloadData()
                } else if let _ = result.invalidProductIDs.first {
                    ShowErrMsg(code: 0, msg: "商品已過期 請重新查詢", vc: self)
                } else {
                    print("Error: \(String(describing: result.error))")
                }
            }
        }
    }
        
    func callInitPayService()
    {
        let request = createHttpRequest(Url: globalData.QueryVipPaymentUrl_lv2, HttpType: "POST", Data: "token=\(globalData.token)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        for item in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpPro = Product()
                            tmpPro.item_id = item["item_id"]  as! String
                            tmpPro.productID = item["product_id"] as! String
                            tmpPro.item_memo = item["item_memo"] as! String
                            tmpPro.amount = item["amount"] as! String
                            self.productArray.append(tmpPro)
                        }
                        self.getInfo()
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
        
    func callGetDvipOrderNoService(productID: String,item_id: String) {
        let request = createHttpRequest(Url: globalData.GetDvipOrderNoUrl, HttpType: "POST", Data: "token=\(globalData.token)&item_id=\(item_id)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
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
                    if responseJSON["code"] as! Int == 0
                    {
                        if let order = responseJSON["orderNo"] as? String
                        {
                            self.buy(productID: productID, orderNo:order)
                        }
                    }
                    else
                    {
                        dismissAlert(selfVC: self) {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func buy(productID: String, orderNo: String) {
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(purchase: let purchase):
                        print("Success! \(purchase)")
                        if let receiptData = SwiftyStoreKit.localReceiptData {
                            print(receiptData.base64EncodedString())
                            let receipt = receiptData.base64EncodedString()
                                .replacingOccurrences(of: "+", with: "%2B")
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: "\r", with: "")
                            dismissAlert(selfVC: self)
                            if self.from == "查看誰對我有興趣" {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideBlurView"), object: nil)
                            }
                            self.calliosPayService(orderNo: orderNo,receipt: receipt)  //Send to my server
                        }
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        break
                    case .error(error: let error):
                        print(error)
                        dismissAlert(selfVC: self) {
                            shortInfoMsg(msg: "無法連接iTunes Store\n請再試一次", vc: self,sec: 2)
                        }
                    }
                }
            }
        }
    }
        
    func calliosPayService(orderNo: String,receipt: String)
    {
        let request = createHttpRequest(Url: globalData.iosPayUrl, HttpType: "POST", Data: "token=\(globalData.token)&isTest=\(globalData.testPay)&receipt=\(receipt)&orderNo=\(orderNo)&paySource=\(from)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        NotificationCenter.default.post(name: Notifications.queryUser, object: nil)
                        self.back(0)
                    }
                    else
                    {
                        self.back(0)
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkIfPurchaed ()
    {
        let alert = GetLoadingView(msg: "處理中...")
        present(alert, animated: true)
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "45532437159b47cf8f1eeb2fe93feb84")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = globalData.last_productId
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, //or .nonRenewing
                    productId: productId,
                    inReceipt: receipt)

                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                        self.receiptInfo_array.append(receipts)
                    }
                    var latest_receipt = receipt["latest_receipt"] as! String
                    latest_receipt = latest_receipt
                    .replacingOccurrences(of: "+", with: "%2B")
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\r", with: "")
                    self.callIosPayReduction(receipt: latest_receipt)
                case .notPurchased:
                    dismissAlert(selfVC: self) {
                        shortInfoMsg(msg: "查無購買紀錄", vc: self, sec: 2)
                    }
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                dismissAlert(selfVC: self) {
                    shortInfoMsg(msg: "查無購買紀錄", vc: self, sec: 2)
                }
            }
        }
    }
    
    func callIosPayReduction(receipt: String) {
        let request = createHttpRequest(Url: globalData.IosPayReductionUrl, HttpType: "POST", Data: "token=\(globalData.token)&isTest=\(globalData.testPay)&receipt=\(receipt)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
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
                    dismissAlert(selfVC: self)
                    {
                        if responseJSON["code"] as! Int == 0
                        {
                            shortInfoMsg(msg: "恢復購買完成", vc: self,sec: 2)
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
    
    //MARK: - collectionView設定
    func collectionViewLayout()
    {
        let flowLayout = UICollectionViewLeftAlignedLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: (self.view.frame.width - 10)/3 , height: 170)
        cv_buy.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "Buu", for: indexPath) as! BuyVipCell
        let pro = productArray[indexPath.item]
        cell.init_buyVipBtn(item_memo: pro.item_memo, amount: pro.amount, item_id: pro.item_id, productID: pro.productID, width: (self.view.frame.width - 10)/3)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BuyVipCell
        cell?.selectItem()
        self.selectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BuyVipCell
        cell?.deselectItem()
        self.selectedIndexPath = nil
    }
   
    @objc func timerAction() {
        if globalData.manVipPicArray.count > 0 {
            var newPage = Int(sv_banner.contentOffset.x / sv_banner.frame.size.width) + 1
            if newPage >= globalData.manVipPicArray.count {newPage = 0}
            sv_banner.setContentOffset( CGPoint(x: sv_banner.frame.width * CGFloat(newPage),y: 0), animated: true)
        }
    }
        
    @IBAction func next(_ sender: Any) {
        if seleProductID == "" || seleItem_id == "" {
            shortInfoMsg(msg: "請選擇項目", vc: self, sec: 2)
        } else {
            let alert = GetLoadingView(msg: "處理中...")
            present(alert, animated: true)
            callGetDvipOrderNoService(productID: seleProductID, item_id: seleItem_id)
        }
    }
        
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func restorePurchase(_ sender: Any) {
        checkIfPurchaed()
    }
}

extension BuyVipVC: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            let currentPage = Int(sv_banner.contentOffset.x / sv_banner.frame.size.width)
            pc_banner.currentPage = currentPage
        }
    }
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {timer.invalidate()}
    }
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.tag == 1 {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(timerAction)), userInfo: nil, repeats: true)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            let currentPage = Int(sv_banner.contentOffset.x / sv_banner.frame.size.width)
            pc_banner.currentPage = currentPage
        }
    }
}
