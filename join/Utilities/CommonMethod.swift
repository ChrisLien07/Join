//
//  CommonMethod.swift
//  join
//
//  Created by 連亮涵 on 2020/5/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//
import UIKit
import Photos
import SDWebImage
import Firebase
import FirebaseStorage
import MapKit

func combineArray(idArr:[String] , txtArr:[String]) -> [Combine]
{
    var combineArr: [Combine] = [Combine]()
    for i in 0...idArr.count - 1
    {
        let tmp = Combine()
        tmp.txt = txtArr[i]
        tmp.id = idArr[i]
        combineArr.append(tmp)
    }
    return combineArr
}

func getImg(asset: PHAsset) -> UIImage? {
    //取得圖片
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.resizeMode = .none
    options.isNetworkAccessAllowed = true
    options.version = .current
    var image: UIImage? = nil
    _ = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
        if let data = imageData {
            image = UIImage(data: data)
        }
    }
    return image
}

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}

func DownloadImage(view: UIImageView, img:String, id: String, placeholder: UIImage?) {
    if img.starts(with: "http"), verifyUrl(urlString: img) {
        let imgURL = URL(string: img)!
        view.sd_setImage(with: imgURL, placeholderImage: placeholder)
    } else {
        NetworkManager.shared.callLogSaveService(id: id, img: img) { (code, msg) in }
    }
}

func changeformat (string: String) -> String {
    let MM = (string as NSString).substring(with: NSMakeRange(0,2))
    let yyyy = (string as NSString).substring(with: NSMakeRange(6,4))
    let dd = (string as NSString).substring(with: NSMakeRange(3,2))
    let newDate : String = "\(yyyy)-\(MM)-\(dd)"
    return newDate
}

func changeformat2 (string: String, part: String) -> String {
    var newDate : String = ""
    if string != ""
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: string)
        
        let yyyy = (string as NSString).substring(with: NSMakeRange(0,4))
        let MM = (string as NSString).substring(with: NSMakeRange(5,2))
        let dd = (string as NSString).substring(with: NSMakeRange(8,2))
        let time = (string as NSString).substring(with: NSMakeRange(11,5))
        
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date!)
        let weekday = dateComponents.weekday!
        var day : String = ""
        if weekday == 2{day = "(一)"}
        else if weekday == 3{day = "(二)"}
        else if weekday == 4{day = "(三)"}
        else if weekday == 5{day = "(四)"}
        else if weekday == 6{day = "(五)"}
        else if weekday == 7{day = "(六)"}
        else if weekday == 1{day = "(日)"}

        if part == "yyyy" {
            newDate = "\(yyyy)"
        } else if part == "MM/dd" {
            newDate = "\(MM)/\(dd)"
        } else if part == "daytime" {
            newDate = "\(day)\(time)"
        } else if part == "all" {
            newDate = "\(yyyy)/\(MM)/\(dd)\(day) \(time)"
        }
    }
    return newDate
}

func GetLoadingView(msg: String) -> UIAlertController
{
    let attributedString = NSAttributedString(string: msg, attributes: [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18),
        NSAttributedString.Key.foregroundColor : globalData.loadingColor])
    let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
    alert.setValue(attributedString, forKey: "attributedMessage")
    alert.view.tintColor = Colors.themePurple
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.gray
    loadingIndicator.color = .black
    loadingIndicator.startAnimating();
    alert.view.addSubview(loadingIndicator)
    return alert
}

func returnToLogin(vc: UIViewController,tbc : MainTabBar,msg : String) {
    shortInfoMsg(msg: msg, vc: vc, sec: 2){
        tbc.dismiss(animated: true){
            NotificationCenter.default.post(name: Notifications.autoLogin, object: nil)
        }
    }
}

func dismissAlert(selfVC: UIViewController, completion: (() -> Void)? = nil) {
    if let vc = selfVC.presentedViewController, vc is UIAlertController {
        DispatchQueue.main.async {
            selfVC.dismiss(animated: false, completion: completion)
        }
    }
}

func shortInfoMsg(msg: String, vc:UIViewController, sec: Double? = nil, completion: (() -> Void)? = nil) {
    //顯示短時間自動消失訊息
    let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
    //顯示提示框
    vc.present(alertController, animated: true, completion: nil)
    //一秒後消失
    if (sec != nil)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + sec!) {
            vc.presentedViewController?.dismiss(animated: true, completion: completion)
        }
    }
}

func ShowErrMsg(code: Int,msg: String, vc:UIViewController) {
    if code == 93 {
        ShowCheckMsg(title: "該帳號閒置過久\n或已從其他裝置登入", msg: "", vc: vc,returnToLogin: true)
    } else {
        ShowCheckMsg(title: (code == 0) ? msg : msg, msg: "", vc: vc)
    }
}

func ShowCheckMsg(title: String,msg: String,vc:UIViewController,returnToLogin: Bool = false) {
    DispatchQueue.main.async {
        //顯示
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default){ (UIAlertAction) in
            if returnToLogin{
                if vc.tabBarController == nil{
                    vc.dismiss(animated: true) { NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BackToLogin"), object: nil) }
                }
                else
                { NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BackToLogin"), object: nil) }
            }
        }
        alertController.addAction(okAction)
        //顯示提示框
        vc.present(alertController, animated: true, completion: nil)
    }
}

func createHttpRequest(Url:String ,HttpType:String,Data:String) -> URLRequest
{
    //創建HttpRequest
    if (HttpType == "POST" || HttpType == "GET")
    {
        var UrlStr = globalData.WebSiteUrl + Url
        if HttpType == "GET"{UrlStr += "/?" + Data}
        var request = URLRequest(url: URL(string:UrlStr)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HttpType
        if HttpType == "POST"{request.httpBody = Data.data(using: .utf8)}
        return request
    }
    else {return URLRequest(url: URL(string: "")!)}
    
}

func getTPETime(format: String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8")
    return dateFormatter.string(from: Date())
}

func clearTmpData()
{
    globalData.tmpName = ""
    globalData.tmpBirthday = ""
    globalData.tmpUserInfo = ""
    globalData.tmpInterest = Combine()
    globalData.tmpConstellation = Combine()
    globalData.tmpLocation = Combine()
    globalData.tmpJob = Combine()
    globalData.tmpBloodtype = Combine()
    globalData.tmpPersonality = Combine()
    globalData.tmpRelationship = Combine()
    
}

func getJsonValueString(_ json: [String:Any], key: String) -> String
{
    if json.keys.contains(key) {
        return json[key] as? String ?? ""
    } else {
        return ""
    }
}

func below(_ target : UIView) -> CGFloat {
    return target.frame.origin.y + target.frame.height
}

func after(_ target : UIView) -> CGFloat {
    return target.frame.origin.x + target.frame.width
}

func fixText(_ string: String) -> String {
    let tmptext = string.replacingOccurrences(of: "&lt;", with: "<")
    return tmptext.replacingOccurrences(of: "&gt;", with: ">")
}
