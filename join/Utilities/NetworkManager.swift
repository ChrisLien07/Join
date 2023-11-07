//
//  Service.swift
//  join
//
//  Created by ChrisLien on 2020/11/19.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    //MARK: - 維修公告
    func callCheckAnnouncementService(completion: @escaping(Int) -> Void) {
        let url = URL(string: "https://www.bc9in.com/web/announcement.html")
        
        let task = URLSession.shared.dataTask(with: url!){ data, response, error in
            guard let data = data, error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if responseJSON["maintenance"] as! Int == 0 {
                    completion(0)
                } else {
                    completion(1)
                }
            }
        }
        task.resume()
    }
    //MARK:- 無回傳
    private func callnoValueReturnService(request: URLRequest, completion: @escaping(Int, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                completion(2, nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        completion(0, nil)
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        completion(128, msg + reason)
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //聚會留言
//    func callPartyCommentService(comtType: Int, id: String, text: String, isPublic: String, completion: @escaping(Int, String?) -> Void) {
//        var url : String = ""
//        var data: String = ""
//        let newText = text.replacingOccurrences(of: "+", with: "%2B")
//        if comtType == 0 {
//            url = globalData.NewPtComtFUrl
//            data = "token=\(globalData.token)&ptid=\(id)&text=\(newText)&isPublic=\(isPublic)"
//        }
//        else if comtType == 1 {
//            url = globalData.NewPtComtSUrl
//            data = "token=\(globalData.token)&cmtid=\(id)&text=\(newText)&isPublic=\(isPublic)"
//        }
//        let request = createHttpRequest(Url: url, HttpType: "POST", Data: data)
//        callnoValueReturnService(request: request, completion: completion)
//    }
    
    //發訊息
    func callSendMsgService(recieveuid: String, message: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.SendMsgUrl , HttpType: "POST", Data: "token=\(globalData.token)&recieveuid=\(recieveuid)&message=\(message)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //一件讀取所有通知
    func callReadAllNotifyService(completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.ReadAllNotifyUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //寫入Log
    func callLogSaveService(id: String, img: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.LogSaveUrl, HttpType: "POST", Data: "token=\(globalData.token)&api_name=\(id)&log_type=\("Error")&error_code=\("0")&error_msg=\(img)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //檢舉用戶
    func callReportService(target: String, id: String, accuse_reason: String, completion: @escaping(Int, String?) -> Void) {
        var data = ""
        var url = ""

        switch target {
        case "user":
            url = globalData.AccuseUserUrl
            data = "token=\(globalData.token)&accuseduid=\(id)&accuse_reason=\(accuse_reason)"
        case "post":
            url = globalData.AccusePostUrl
            data = "token=\(globalData.token)&pid=\(id)&accuse_reason=\(accuse_reason)"
        case "party":
            url = globalData.AccusePartyUrl
            data = "token=\(globalData.token)&ptid=\(id)&accuse_reason=\(accuse_reason)"
        default:
            break
        }
        
        let request = createHttpRequest(Url: url, HttpType: "POST", Data: data)
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //封鎖用戶
    func callBlockUserService(uid: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.BlockUserUrl, HttpType: "POST", Data: "token=\(globalData.token)&frienduid=\(uid)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //評分
    func callRateService(uid: String, starRating: String, text: String, completion: @escaping (Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.ReviewUserUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\(uid)&starRating=\(starRating)&text=\(text)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //刪除聚會
    func callDeletPartyService(ptid: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.DeletePartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)")
        callnoValueReturnService(request: request, completion: completion)
    }
        
    //iosPay
    func calliosPayService(orderNo: String, receipt: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.iosPayUrl, HttpType: "POST", Data: "token=\(globalData.token)&isTest=\(globalData.testPay)&receipt=\(receipt)&orderNo=\(orderNo)")
      callnoValueReturnService(request: request, completion: completion)
    }
    
    //推播是否顯示訊息內容(1:顯示,0:不顯示)
    func callUpdateisShowMsgNotifyService(status: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.UpdateUserUrl, HttpType: "POST", Data: "token=\(globalData.token)&isShowMsgNotify=\(status)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //確認用戶是否在出席名單裡
    func callCheckUserAttendanceService(ptid: String, atUid: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.CheckUserAttendanceUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&atUid=\(atUid)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //聊天室送圖片
    func callSendImgeService(recieveuid: String, completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.SendImgUrl, HttpType: "POST", Data: "token=\(globalData.token)&recieveuid=\(recieveuid)")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //檢查po隨手拍次數限制
    func callCheckPostService(completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.CheckNewPostUrl, HttpType: "POST", Data: "token=\(globalData.token)&source=\("ios")")
        callnoValueReturnService(request: request, completion: completion)
    }
    
    //檢查po揪一起次數限制
    func callCheckPartyService(completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.CheckNewPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&source=\("ios")")
        callnoValueReturnService(request: request, completion: completion)
    }
    //MARK: -ReturnValue
    
    //取得用戶所有評論
    func callGetReviewService(uid: String, completion: @escaping(Int, [Review]?, String) -> Void)
    {
        let request = createHttpRequest(Url: globalData.GetReviewUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\(uid)")
        let task = URLSession.shared.dataTask(with: request)
        {data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,"0")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        var reviews: [Review] = []
                        let list = responseJSON["list"] as! [[String: Any]]
                        for rev in list {
                            let tmpReview = Review()
                            parseReview(review: tmpReview, rev: rev)
                            reviews.append(tmpReview)
                        }
                        let avgStarRating = responseJSON["avgStarRating"] as! String
                        completion(0,reviews,avgStarRating)
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        completion(127,nil,"0")
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, responseJSON["msg"] as! String)
                    }
                }
            }
        }
        task.resume()
    }

    //開啟私訊聊天室
    func callOpenDMChatService(frienduid: String, completion: @escaping(Int,String?,String?) -> Void) {
        let request = createHttpRequest(Url: globalData.OpenDMChatUrl, HttpType: "POST", Data: "token=\(globalData.token)&frienduid=\(frienduid)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request)
        {data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        let chtid = responseJSON["chtid"] as! String
                        completion(0,chtid,nil)
                    }
                    else if responseJSON["code"] as! Int == 148
                    {
                        completion(148,nil,nil)
                    }
                    else if responseJSON["code"] as! Int == 100148 {
                        completion(100148,nil,nil)
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        completion(128, nil, msg + reason)
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //出席名單
    func callGetAttendListService(ptid: String, completion: @escaping(Int,[AttendanceList]?,String?) -> Void) {
        let request = createHttpRequest(Url: globalData.GetAttendanceListUrl, HttpType: "POST", Data:"token=\(globalData.token)&ptid=\(ptid)")
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,nil)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                   
                    if responseJSON["code"] as! Int == 0
                    {
                        
                        var attList: [AttendanceList] = []
                        for att in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpAttList = AttendanceList()
                            parseAttendList(attendanceList: tmpAttList , attList: att)
                            attList.append(tmpAttList)
                        }
                        completion(0,attList,nil)
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        completion(127,nil,nil)
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //取得聚會留言
    func callGetPartyComtService(ptid: String, isPublic: String, completion: @escaping(Int,[[String: Any]]?,String?) -> Void)
    {
        let request = createHttpRequest(Url: globalData.GetPartyComtUrl , HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)&isPublic=\(isPublic)&block=\("")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        completion(0, (responseJSON["list"] as! [[String: Any]]), nil)
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        completion(127,nil,nil)
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //產生訂單編號
    func callGetDvipOrderNoService(completion: @escaping(Int,String?,String?) -> Void) {
        let request = createHttpRequest(Url: globalData.GetDvipOrderNoUrl, HttpType: "POST", Data: "token=\(globalData.token)&item_id=\(globalData.item_id)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        completion(0, (responseJSON["orderNo"] as! String), nil)
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //取得公告
    func callGetAnnouncementListService(completion: @escaping(Int,String?,String?,String?) -> Void) {
        print(globalData.token)
        let request = createHttpRequest(Url: globalData.GetAnnouncementListUrl, HttpType: "POST", Data: "token=\(globalData.token)&maxlimit=\("1")&target=\("ios")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                error == nil else
            {
                completion(2,nil,nil, nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        let list = responseJSON["list"] as! [[String: Any]]
                        if list.count != 0 {
                            completion(0, (list[0]["title"] as! String), (list[0]["content"] as! String), nil)
                        } else {
                            completion(0, nil, nil, nil)
                        }
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    func callCheckisvip(completion: @escaping(Int, String?) -> Void) {
        let request = createHttpRequest(Url: globalData.Checkisviplv2Url, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data,
                  error == nil else {
                completion(2,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let isVip = responseJSON["isvip"] as? String
                        {
                            globalData.isVip = isVip
                            completion(0,isVip)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //取得個人資訊
    func callQueryUserService(completion: @escaping() -> Void) {
        let request = createHttpRequest(Url: globalData.QueryUser_MyPageUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data,
                  error == nil else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        if let info = responseJSON["list"] as? [[String: Any]]
                        {
                            parseUserInfo(info: info[0])
                            globalData.location_rq_array = (info[0]["location_rq_name"] as! String).components(separatedBy: ",")
                            globalData.location_rq_combine_array = combineArray(idArr: (info[0]["location_rq"] as! String).components(separatedBy: ","), txtArr:globalData.location_rq_array)
                            completion()
                        }
                    }
                }
            }
        }
        task.resume()
    }

    //取得喜歡我人數
    func callQueryLikeMEService(completion: @escaping(Int,Int?,String?) -> Void) {
        let request = createHttpRequest(Url: globalData.QueryLikeMeUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(0)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data,
                  error == nil else
            {
                completion(2,nil,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        DispatchQueue.main.async {
                            let cnt = responseJSON["count"] as? Int ?? 0
                            completion(0,cnt,nil)
                        }
                    }
                    else
                    {
                        completion(responseJSON["code"] as! Int, nil, (responseJSON["msg"] as! String))
                    }
                }
            }
        }
        task.resume()
    }
    
    //搜尋貼文
    func callSearchPostService(text: String, completion: @escaping(Int,[Search]?) -> Void) {
        let request = createHttpRequest(Url: globalData.SearchPostUrl, HttpType: "POST", Data: "token=\(globalData.token)&keyword=\(text)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                completion(2,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0 {
                        
                        var posts: [Search] = []
                        for post in responseJSON["list"] as! [[String: Any]]
                        {
                            let search = Search()
                            parseSearchs(search: search, sear: post)
                            posts.append(search)
                        }
                        completion(0,posts)
                    }
                    else
                    {
                        completion(127,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    //搜尋聚會
    func callSearchPartyService(text: String, city: String, completion: @escaping(Int,[Search]?) -> Void) {
        let request = createHttpRequest(Url: globalData.SearchPartyUrl, HttpType: "POST", Data: "token=\(globalData.token)&keyword=\(text)&location=\(city)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                completion(2,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0 {
                        var partys: [Search] = []
                        for party in responseJSON["list"] as! [[String: Any]]
                        {
                            let search = Search()
                            parseSearchs(search: search, sear: party)
                            partys.append(search)
                        }
                        completion(0,partys)
                    }
                    else
                    {
                        completion(127,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    //取得成為好友時間
    func callGetChatroomCreateTimeService(chtid: String, completion: @escaping(Int,String?) -> Void) {
        let request = createHttpRequest(Url: globalData.GetChatroomCreateTimeUrl, HttpType: "POST", Data: "token=\(globalData.token)&chtid=\(chtid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                completion(2,nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0 {
                        let createTimeSpan = responseJSON["createTimeSpan"] as! String
                        completion(0,createTimeSpan)
                    }
                    else
                    {
                        completion(127,nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkIfPurchased(completion: @escaping(Result<String,JoinError>) -> Void) {
        var receiptInfo_array: [ReceiptInfo] = [ReceiptInfo]()
        
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
                case .purchased(_, _):
                    for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                        receiptInfo_array.append(receipts)
                    }
                    let r = receiptInfo_array[0]
                    if globalData.transaction_id != r["transaction_id"] as? String ?? "" {
                        var latest_receipt = receipt["latest_receipt"] as! String
                        latest_receipt = latest_receipt
                        .replacingOccurrences(of: "+", with: "%2B")
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "\r", with: "")
                        completion(.success(latest_receipt))
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    
                    for receipts in receipt["latest_receipt_info"] as! [ReceiptInfo] {
                        receiptInfo_array.append(receipts)
                    }
                    let r = receiptInfo_array[0]
                    if globalData.transaction_id != r["transaction_id"] as? String ?? "" {
                        var latest_receipt = receipt["latest_receipt"] as! String
                        latest_receipt = latest_receipt
                        .replacingOccurrences(of: "+", with: "%2B")
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "\r", with: "")
                        completion(.success(latest_receipt))
                    }
                case .notPurchased:
                    completion(.failure(.notPurchased))
                }
            case .error(_):
                completion(.failure(.otherError))
            }
        }
    }
}
