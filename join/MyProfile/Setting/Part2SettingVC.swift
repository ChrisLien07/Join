//
//  Part2SettingVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseAuth

class Part2SettingVC: UIViewController {

    @IBOutlet weak var v_block: UIView!
    @IBOutlet weak var v_logout: UIView!
    @IBOutlet weak var lbl_appVersion: UILabel!
    @IBOutlet weak var chatSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapBlock  = UITapGestureRecognizer.init(target: self, action: #selector(goBlock))
        v_block.addGestureRecognizer(tapBlock)
        let tapLogout = UITapGestureRecognizer.init(target: self, action: #selector(logout))
        v_logout.addGestureRecognizer(tapLogout)
        lbl_appVersion.text = "APP版本: " + globalData.appVersion
        
        if globalData.isShowMsgNotify == "1" {
            chatSwitch.isOn = true
        } else {
            chatSwitch.isOn = false
        }
    }
    
    func changeShowMsgNotifyStatus(status: String) {
        NetworkManager.shared.callUpdateisShowMsgNotifyService(status: status) { (code, msg) in
            if status == "1" {
                globalData.isShowMsgNotify = "1"
            } else {
                globalData.isShowMsgNotify = "0"
            }
        }
    }
    
    @objc func goBlock()
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserListCell") as! UserListTableVC
        vc.from = "block"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logout()
    {
        let alertController = UIAlertController(title: "是否確定登出？", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default,handler: {(_) in
            if Auth.auth().currentUser != nil
            {
                try! Auth.auth().signOut()
                if let tbc = self.tabBarController as? MainTabBar
                {
                    
                    let userdefaults = UserDefaults.standard
                    UserDefaults.standard.removeObject(forKey: "Token")
                    userdefaults.synchronize()
                    returnToLogin(vc: self, tbc: tbc, msg: "登出成功")
                }
            }
        })
        alertController.addAction(okAction)
        alertController.addAction(UIAlertAction(title:"取消",style: .cancel))
        //顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func change(_ sender: Any) {
        if chatSwitch.isOn {
            changeShowMsgNotifyStatus(status: "1")
        } else {
            changeShowMsgNotifyStatus(status: "0")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
