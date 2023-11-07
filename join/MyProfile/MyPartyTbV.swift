//
//  MyPartyTbV.swift
//  join
//
//  Created by ChrisLien on 2020/10/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MyPartyTbV: UITableViewController {
    
    var myPartyArray: [Search] = [Search]()
    var historyPartyArray:[Search] = [Search]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callMyPartyService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "我的聚會"
        hideMainBar()
    }
    
    func callMyPartyService(){
       
        let request = createHttpRequest(Url: globalData.GetPartyListUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(0)&type=\("2")")
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
                        self.myPartyArray.removeAll()
                        self.historyPartyArray.removeAll()
                        for sear in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpSear = Search()
                            parseSearchs(search: tmpSear, sear: sear)
                            let dateformat = DateFormatter()
                            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            dateformat.locale = Locale(identifier: "zh_CN")
                            let tmpcreattime = dateformat.date(from: tmpSear.starttime)!
                            tmpSear.timestamp = String(tmpcreattime.timeIntervalSince1970*1000)
                            if tmpSear.isExpired == "1" {
                                self.historyPartyArray.append(tmpSear)
                            } else if tmpSear.isExpired == "0" {
                                self.myPartyArray.append(tmpSear)
                            }
                        }
                        self.historyPartyArray.sort { $0.timestamp > $1.timestamp }
                        self.myPartyArray.sort { $0.timestamp > $1.timestamp }
                        self.tableView.reloadData()
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        self.myPartyArray.removeAll()
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

    @objc func refresh()
    {
        callMyPartyService()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section)
        {
        case 0:
            return myPartyArray.count
        case 1:
            return historyPartyArray.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPartyCell", for: indexPath) as! MyPartyCell
        cell.selectionStyle = .none
        if indexPath.section == 0
        {
            let party = myPartyArray[indexPath.row]
            cell.initParty(ptid: party.ptid, uid: party.uid, img_url: party.img_url, title: party.title, starttime: party.starttime, address: party.address, isExpired: party.isExpired, height: view.frame.width * 9 / 18, width: view.frame.width - 30)
            
        }
        else if indexPath.section == 1
        {
            let party = historyPartyArray[indexPath.row]
            cell.initParty(ptid: party.ptid, uid: party.uid, img_url: party.img_url, title: party.title, starttime: party.starttime, address: party.address, isExpired: party.isExpired, height: view.frame.width * 9 / 18, width: view.frame.width - 30)
        }
        if indexPath.row == 0
        {
            cell.v_main.frame = CGRect(x:15,y:15,width: view.frame.width - 30,height: view.frame.width * 9 / 18)
        }
     
        cell.img_post.layer.cornerRadius = 10
        cell.img_post.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section)
        {
        case 1:
            return 20
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (section)
        {
        case 1:
            let v = UIView()
            let lbl_text = UILabel()
            lbl_text.text = "歷史紀錄"
            lbl_text.font = .systemFont(ofSize: 16)
            lbl_text.frame = CGRect(x: 15, y: 5, width: 70, height: 17)
            lbl_text.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
            v.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
            v.addSubview(lbl_text)
            return v
        default:
            let v = UIView()
            return v
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0
        {
            return (view.frame.width * 9 / 18) + 25
        }
        else
        {
            return (view.frame.width * 9 / 18) + 16
        }
    }
}
