//
//  ListsVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/6.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ListsVC: UIViewController {

    @IBOutlet weak var v_apply: UIView!
    @IBOutlet weak var lbl_appliers: UILabel!
    @IBOutlet weak var v_participate: UIView!
    @IBOutlet weak var lbl_participants: UILabel!
    @IBOutlet weak var btn_partyFull: UIButton!
    
    var applier_arry:[AttendanceList] = [AttendanceList]()
    var participant_arry:[AttendanceList] = [AttendanceList]()
    var ptid: String = ""
    var isAllow = ""
    var isExpired = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let goParticipantsList  = UITapGestureRecognizer.init(target: self, action: #selector(goParticipants))
        v_participate.addGestureRecognizer(goParticipantsList)
        let goApplierList = UITapGestureRecognizer.init(target: self, action: #selector(goApplier))
        v_apply.addGestureRecognizer(goApplierList)
        //
        if isAllow == "0" {
            btn_partyFull.setTitle("取消滿團", for: .normal)
        } else if isAllow == "1" {
            btn_partyFull.setTitle("宣告滿團", for: .normal)
        }
        btn_partyFull.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_partyFull.frame.height/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAttendanceList(ptid: ptid)
        callGetUnreviewedListService()
    }
    
    func getAttendanceList(ptid : String) {
        NetworkManager.shared.callGetAttendListService(ptid: ptid) { (code, list, msg) in
            
            self.participant_arry.removeAll()
    
            switch code {
            case 0:
                self.participant_arry = list!
                self.lbl_participants.text = "總共\(self.participant_arry.count)人參加"
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                self.lbl_participants.text = "總共0人參加"
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
            }
        }
    }
    
    func callGetUnreviewedListService() {
        let request = createHttpRequest(Url: globalData.GetUnreviewedListUrl, HttpType: "POST", Data: "token=\(globalData.token)&ptid=\(ptid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
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
                        self.applier_arry.removeAll()
                        for attList in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpAttList = AttendanceList()
                            parseAttendList(attendanceList: tmpAttList , attList: attList)
                            self.applier_arry.append(tmpAttList)
                        }
                        self.lbl_appliers.text = "總共\(self.applier_arry.count)人報名"
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        self.applier_arry.removeAll()
                        self.lbl_appliers.text = "總共0人報名"
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
    
    func callAllowForbidPartyService()
    {
        var url = ""
        if isAllow == "0"
        {
            url = globalData.AllowJoinPartyUrl
        }
        else if isAllow == "1"
        {
            url = globalData.ForbidJoinPartyUrl
        }
        let request = createHttpRequest(Url: url, HttpType: "POST", Data:"token=\(globalData.token)&ptid=\(ptid)")
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                self.btn_partyFull.isEnabled = true
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        if self.isAllow == "0"
                        {
                            self.isAllow = "1"
                            self.btn_partyFull.setTitle("宣告滿團", for: .normal)
                        }
                        else if self.isAllow == "1"
                        {
                            self.isAllow = "0"
                            self.btn_partyFull.setTitle("取消滿團", for: .normal)
                        }
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                    self.btn_partyFull.isEnabled = true
                }
            }
        }
        task.resume()
    }
    
    @objc func goParticipants() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ParticipantsListTbV") as! ParticipantsListTbV
        vc.participant_arry = participant_arry
        vc.ptid = ptid
        vc.isExpired = isExpired
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goApplier() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ApplierListTbV") as! ApplierListTbV
        vc.applier_arry = self.applier_arry
        vc.ptid = self.ptid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func partyFull(_ sender: Any) {
        btn_partyFull.isEnabled = false
        callAllowForbidPartyService()
    }
   
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
