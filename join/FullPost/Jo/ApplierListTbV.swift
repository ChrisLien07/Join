//
//  ApplierListTbV.swift
//  join
//
//  Created by ChrisLien on 2020/10/7.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ApplierListTbV: UIViewController {

    @IBOutlet weak var tbv_applier: UITableView!
    @IBOutlet weak var lbl_applier: UILabel!
    
    var applier_arry: [AttendanceList] = [AttendanceList]()
    var uidListArr: [String] = [String]()
    var ptid: String = ""
    var isEdited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hideMainBar()
        configureTableView()
        lbl_applier.text = "共\(self.applier_arry.count)位報名，尚未審核通過"
    }
    
    func configureTableView() {
        setTableViewDelegates()
        tbv_applier.allowsSelection = false
        tbv_applier.allowsMultipleSelectionDuringEditing = true
    }
    
    func setTableViewDelegates() {
        tbv_applier.delegate = self
        tbv_applier.dataSource = self
    }
    
    func callGetUnreviewedListService()
    {
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
                        self.lbl_applier.text = "共\(self.applier_arry.count)位報名，尚未審核通過"
                        self.tbv_applier.reloadData()
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        self.lbl_applier.text = "共0位報名，尚未審核通過"
                        self.tbv_applier.reloadData()
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
    
    func callAuditService()
    {
        let uidList = uidListArr.joined(separator:",")
        let request = createHttpRequest(Url: globalData.AuditParticipantUrl , HttpType: "POST", Data:"token=\(globalData.token)&ptid=\(ptid)&uidlist=\(uidList)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,  error == nil else
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
                        self.applier_arry.removeAll()
                        self.callGetUnreviewedListService()
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated:  true)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        self.tbv_applier.isEditing = !self.tbv_applier.isEditing
        sender.title = (self.tbv_applier.isEditing) ? "完成" : "審核"
        if tbv_applier.isEditing {
            isEdited = true
            uidListArr.removeAll()
            self.tbv_applier.reloadData()
        } else {
            isEdited = false
            if uidListArr.count > 0 {
                callAuditService()
            }
            self.tbv_applier.reloadData()
        }
    }
}
    
extension ApplierListTbV: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applier_arry.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applierList", for: indexPath) as! ApplierListCell
        let applier = applier_arry[indexPath.row]
        cell.initAttList(uid: applier.uid , username: applier.username, img_url: applier.img_url, age: applier.age, timespan: applier.timespan, location_Name: applier.location_Name, height: 60, width: view.frame.width, isEdited: self.isEdited)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uidListArr.append(applier_arry[indexPath.row].uid)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        uidListArr = uidListArr.filter(){$0 != applier_arry[indexPath.row].uid}
    }
}
    
    
