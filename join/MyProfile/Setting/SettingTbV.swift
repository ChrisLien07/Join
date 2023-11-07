//
//  SettingTbV.swift
//  join
//
//  Created by 連亮涵 on 2020/7/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingTbV: UITableViewController {

    let titleArray : [String] = ["我的VIP","查看誰喜歡我","聯絡我們","設定","常見問題QA","使用條款&隱私權政策"]
    let imgArray : [String] = ["001-crown","heart-solid-19pt × 16pt","outline_email_black_24pt","baseline_tune_black_24pt","outline_info_black_24pt","baseline_notes_black_24pt"]
    
    var likeArray:[QueryLikeMe] = [QueryLikeMe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callQueryLikeMEService()
    }
    
    func callQueryLikeMEService() {
        let request = createHttpRequest(Url: globalData.QueryLikeMeUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(0)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                
                if responseJSON["code"] as! Int == 0
                {
                    DispatchQueue.main.async {
                        self.likeArray.removeAll()
                        for like in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpLike = QueryLikeMe()
                            parseQueryLikeMe(querylikeme: tmpLike, like: like)
                            self.likeArray.append(tmpLike)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        cell.initSetting(title: titleArray[indexPath.row], img: imgArray[indexPath.row] )
        switch titleArray[indexPath.row]
        {
            case "我的VIP":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goVip))
                cell.addGestureRecognizer(tap)
            case "查看誰喜歡我":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goLike))
                cell.addGestureRecognizer(tap)
            case "設定":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goSetting2))
                cell.addGestureRecognizer(tap)
                cell.img_title.tintColor = Colors.postBlue
            case "聯絡我們":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goContact))
                cell.addGestureRecognizer(tap)
                cell.img_title.tintColor = Colors.partyYellow
            case "常見問題QA":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goGuied))
                cell.addGestureRecognizer(tap)
                cell.img_title.tintColor = Colors.themePurple
            case "使用條款&隱私權政策":
                let tap = UITapGestureRecognizer(target: self, action: #selector(goSP))
                cell.addGestureRecognizer(tap)
                cell.img_title.tintColor = Colors.partyYellow
            default: break
        }
        return cell
    }

    @objc func goVip() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingVipPageVC") as! SettingVipPageVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goLike() {
        NetworkManager.shared.callCheckisvip { (code, isvip) in
            switch code {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LikeMeListVC") as! LikeMeListVC
                vc.isVip = isvip!
                vc.likeArray = self.likeArray
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                Alert.ShowConnectErrMsg(vc: self)
            }
        }
    }
    
    @objc func goSetting2() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Part2SettingVC") as! Part2SettingVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goContact() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ContactVC") as! ContactVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goGuied()
    {
        let url = URL(string: "https://www.bc9in.com/web/Q&A.html?isApp=1")!
        UIApplication.shared.open(url)
    }
    
    @objc func goSP()
    {
        let serviceUrl_privacyUrl = URL(string: globalData.serviceUrl_privacyUrl)!
        UIApplication.shared.open(serviceUrl_privacyUrl)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
