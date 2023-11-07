//
//  ParticipantsListTbV.swift
//  join
//
//  Created by ChrisLien on 2020/10/6.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ParticipantsListTbV: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tbv_participant: UITableView!
    @IBOutlet weak var lbl_participant: UILabel!
    
    var participant_arry: [AttendanceList] = []
    var uidListArr: [String] = []
    var ptid = ""
    var isEdited = false
    var isHost = true
    var isExpired = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv_participant.delegate = self
        tbv_participant.dataSource = self
        tbv_participant.allowsSelection = false
        tbv_participant.allowsMultipleSelectionDuringEditing = true
        //
        if !isHost {
            let button = UIButton.init(type: .custom)
            let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            button.frame = buttonView.frame
            buttonView.addSubview(button)
            let rightButton = UIBarButtonItem.init(customView: buttonView)
            self.navigationItem.rightBarButtonItem = rightButton
            getAttendanceList(ptid: ptid)
        }
        self.lbl_participant.text = "總共\(self.participant_arry.count)人出席"
    }
    
    func getAttendanceList(ptid : String) {
        NetworkManager.shared.callGetAttendListService(ptid: ptid) { (code, list, msg) in
            
            self.participant_arry.removeAll()
    
            switch code {
            case 0:
                self.participant_arry = list!
                self.lbl_participant.text = "總共\(self.participant_arry.count)人出席"
                self.tbv_participant.reloadData()
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                self.lbl_participant.text = "總共0人出席"
                self.tbv_participant.reloadData()
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
            }
        }
    }
    
    func callCancelService(uid: String) {
        var data = ""
        let uidList = uidListArr.joined(separator:",")
        if uid == "" {
            data = "token=\(globalData.token)&ptid=\(ptid)&uidlist=\(uidList)"
        } else {
            data = "token=\(globalData.token)&ptid=\(ptid)&uidlist=\(uid)"
        }
        let request = createHttpRequest(Url: globalData.CancelParticipantUrl , HttpType: "POST", Data: data)
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
                        self.participant_arry.removeAll()
                        self.getAttendanceList(ptid: self.ptid)
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
        self.tbv_participant.isEditing = !self.tbv_participant.isEditing

        if tbv_participant.isEditing {
            sender.image = UIImage(named: "")
            isEdited = true
            uidListArr.removeAll()
            self.tbv_participant.reloadData()
        } else {
            sender.image = UIImage(named: "baseline_delete_black_24pt")
            isEdited = false
            if uidListArr.count > 0 {
                callCancelService(uid: "")
            }
            self.tbv_participant.reloadData()
        }
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participant_arry.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participant = participant_arry[indexPath.row]
        if isExpired == "1" , participant.isMyself != "1" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantsRatingCell", for: indexPath) as! ParticipantsRatingCell
            cell.initAttList(uid: participant.uid , username: participant.username, img_url: participant.img_url, age: participant.age, timespan: participant.timespan, location_Name: participant.location_Name, height: self.tbv_participant.rowHeight, width: view.frame.width, isEdited: self.isEdited, starRating: participant.starRating, isExpired: self.isExpired, isHost: participant.isHost, isMyself: participant.isMyself)
            
            cell.v_stars.didFinishTouchingCosmos = { rating in
                let alertController = UIAlertController(title: "評價", message: "請輸入對此用戶的評價。", preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "選填，限50個字元內"
                }
                alertController.addAction(UIAlertAction(title: "送出", style: .default, handler: {(action:UIAlertAction!) -> Void in
                    let review: String = alertController.textFields?[0].text ?? ""
                    NetworkManager.shared.callRateService(uid: participant.uid, starRating: String(rating), text: review) { (code, msg) in
                        switch code {
                        case 0:
                            Alert.successRatingAlert(vc: self)
                            self.getAttendanceList(ptid: self.ptid)
                        case 2:
                            Alert.ShowConnectErrMsg(vc: self)
                        case 128:
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                            vc.reason = msg!
                            self.present(vc, animated: true, completion: nil)
                        default:
                            ShowErrMsg(code: code,msg: msg!,vc: self)
                        }
                    }
                }))
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
                self.present(alertController, animated: true, completion: nil)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "participantList", for: indexPath) as! ParticipantsListCell
            cell.initAttList(uid: participant.uid , username: participant.username, img_url: participant.img_url, age: participant.age, timespan: participant.timespan, location_Name: participant.location_Name, height: self.tbv_participant.rowHeight, width: view.frame.width, isEdited: self.isEdited, isExpired: self.isExpired, isHost: participant.isHost, isMyself: participant.isMyself)
            return cell
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { _,_, completionHandler in
            self.callCancelService(uid: self.participant_arry[indexPath.row].uid)
            self.participant_arry.remove(at: indexPath.row)
            self.tbv_participant.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        if !isHost { return .none } else { return swipeConfiguration }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uidListArr.append(participant_arry[indexPath.row].uid)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        uidListArr = uidListArr.filter(){$0 != participant_arry[indexPath.row].uid}
    }
}
