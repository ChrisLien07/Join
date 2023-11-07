//
//  Alert.swift
//  join
//
//  Created by ChrisLien on 2020/11/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

enum Alert {
    
    static func basicAlert(vc: UIViewController, title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func basicActionAlert(vc: UIViewController, title: String?, message: String?, okBtnTitle: String, twoBtn: Bool, handler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okBtnTitle, style: .default, handler: handler))
        if twoBtn {
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    //MARK: - message
    static func maxPostAlert(vc: UIViewController) {
        basicAlert(vc: vc, title: "本日發文次數已達上限", message: nil)
    }
    
    static func failDeletePartyAlert(vc: UIViewController) {
        basicAlert(vc: vc, title: "無法刪除活動", message: "您的活動出席名單還有參加者，故無法刪除。")
    }
    
    static func fullPartyAlert(view: UIView) {
        basicAlert(vc: view.findViewController()!, title: "已滿團", message: "抱歉，此活動已額滿，揪in還有其他更豐富的活動，您可至首頁搜尋。")
    }
    
    static func successRatingAlert(vc: UIViewController) {
        basicAlert(vc: vc, title: nil, message: "發送評論成功")
    }
    
    static func failRatingAlert(vc: UIViewController, code: String) {
        basicAlert(vc: vc, title: nil, message: "發送評論失敗, code:\(code)")
    }
    
    static func notAllowChatBoardAlert(vc: UIViewController) {
        basicAlert(vc: vc, title: nil, message: "報名活動成功者即可進入團員留言板，想認識團員快手刀報名活動。")
    }
    
    static func atPersonLeavePartyAlert(vc:UIViewController , username: String){
        basicAlert(vc: vc, title: nil, message: "\(username)已離開此聚會")
    }
    //MARK: - action
    
    static func verifyRegistrationAlert(vc: UIViewController, foldername: String) {
        basicActionAlert(vc: vc, title: "提醒", message: "性別、生日選擇之後就無法再更改了", okBtnTitle: "確定", twoBtn: true) { (_) in
            let iconVC = vc.storyboard!.instantiateViewController(withIdentifier: "IconVC") as! UserIconViewController
            iconVC.foldername = foldername
            vc.navigationController?.pushViewController(iconVC, animated: true)
        }
    }
   
    static func buyVIPAlert(vc: UIViewController, title: String, msg: String, from: String) {
        basicActionAlert(vc: vc, title: title, message: msg, okBtnTitle: "升級VIP", twoBtn: true) { (_) in
            let buyVIPVC = vc.storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
            buyVIPVC.from = from
            vc.present(buyVIPVC, animated: true)
        }
    }
    
    static func cancelPostPartyAlert(vc:UIViewController) {
        basicActionAlert(vc: vc, title: "確認取消發佈活動", message: "確定取消此活動? 取消就無法恢復囉!", okBtnTitle: "確定", twoBtn: true) { (_) in
            globalData.tmpAdress = ""
            vc.endEdit()
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    static func successSendPartyAlert(view:UIView) {
        basicActionAlert(vc: view.findViewController()!, title: "報名已傳送", message: "系統已收到您的報名，主辦者審核需1-2天，審核通過將發送通知。", okBtnTitle: "確定", twoBtn: false) { (_) in
            (view.findViewController() as! Jo_FullPostVC).refresh()
        }
    }
    
    static func changedSearchConditionAlert(vc: UIViewController) {
        basicActionAlert(vc: vc, title: "尚未儲存本次設定的條件", message: "確定要放棄本次設定的條件，返回想認識頁面嗎?", okBtnTitle: "確定", twoBtn: true) { (_) in
            vc.showMainBar()
            vc.navigationController?.popViewController(animated: true)
        }
    }
    //MARK: - 連線錯誤
    static func ShowConnectErrMsg(vc:UIViewController) {
        DispatchQueue.main.sync {
            basicActionAlert(vc: vc, title: "連線失敗", message: "請檢查網路連線", okBtnTitle: "確定", twoBtn: false) { (_) in
                NetworkManager.shared.callCheckAnnouncementService { (code) in
                    switch code {
                    case 0:
                        return
                    case 1:
                        DispatchQueue.main.sync {
                            shortInfoMsg(msg: "目前揪in伺服器維護中，敬請見諒。", vc: vc)
                        }
                    default:
                        return
                    }
                }
            }
        }
    }
    
}
