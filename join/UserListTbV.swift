//
//  GpTableVC.swift
//  join
//
//  Created by 連亮涵 on 2020/6/17.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Foundation

class UserListTableVC: UITableViewController {
    
    var gpArray : [UserList] = []
    var followingArray : [UserList] = []
    var followerArray: [UserList] = []
    var blockArray: [Block] = []
    
    var pid = ""
    var from = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refreshBlock"), object: nil)
        //手,TabBar消失
        if from != "postGp" {
            (self.findTabBarController() as! MainTabBar).tabBar.isHidden = true
        }
        //
        if from == "gp" || from == "postGp" {
            self.title = "點讚的人"
            callUserListService()
        } else if from == "following" {
            self.title = "追蹤中"
            callUserListService()
        } else if from == "follower" {
            self.title = "我的粉絲"
            callUserListService()
        } else if from == "block" {
            self.title = "封鎖名單"
            callUserListService()
        }
    }

    func callUserListService()
    {
        var urlLink = ""
        var data = ""
        if from == "gp" || from == "postGp" {
            urlLink = globalData.GetGpListUrl
            data = "token=\(globalData.token)&pid=\(pid)"
        } else if from == "following" {
            urlLink = globalData.GetFollowListUrl
            data = "token=\(globalData.token)"
        } else if from == "follower" {
            urlLink = globalData.GetFollowerListUrl
            data = "token=\(globalData.token)"
        } else if from == "block" {
            urlLink = globalData.GetBlockListUrl
            data = "token=\(globalData.token)"
        }
        let request = createHttpRequest(Url: urlLink, HttpType: "POST", Data: data )
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
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
                        if self.from == "gp" || self.from == "postGp"
                        {
                            self.gpArray.removeAll()
                            for list in responseJSON["list"] as! [[String: Any]]
                            {
                                let tmpUserList = UserList()
                                parseUserList(userList: tmpUserList, list: list)
                                self.gpArray.append(tmpUserList)
                            }
                            self.tableView.reloadData()
                        }
                        else if self.from == "following"
                        {
                            self.followingArray.removeAll()
                            for list in responseJSON["list"] as! [[String: Any]]
                            {
                                let tmpUserList = UserList()
                                parseUserList(userList: tmpUserList, list: list)
                                self.followingArray.append(tmpUserList)
                            }
                            self.tableView.reloadData()
                        }
                        else if self.from == "follower"
                        {
                            self.followerArray.removeAll()
                            for list in responseJSON["list"] as! [[String: Any]]
                            {
                                let tmpUserList = UserList()
                                parseUserList(userList: tmpUserList, list: list)
                                self.followerArray.append(tmpUserList)
                            }
                            self.tableView.reloadData()
                        }
                        else if self.from == "block"
                        {
                            self.blockArray.removeAll()
                            for list in responseJSON["list"] as! [[String: Any]]
                            {
                                let tmpBlock = Block()
                                parseBlck(block: tmpBlock, list: list)
                                self.blockArray.append(tmpBlock)
                            }
                            self.tableView.reloadData()
                        }
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
    //tableView設定-------------------------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch from {
        case "gp":
            return gpArray.count
        case "postGp":
            return gpArray.count
        case "following":
            return followingArray.count
        case "follower":
            return followerArray.count
        case "block":
            return blockArray.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListTableCell
        switch from
        {
        case "gp":
            let g = gpArray[indexPath.row]
            cell.init_userList(user_img:g.img_url, username:g.username, uid: g.uid, height: self.tableView.rowHeight, width: view.frame.width,isBlock:false)
        case "postGp":
            let g = gpArray[indexPath.row]
            cell.init_userList(user_img:g.img_url, username:g.username, uid: g.uid, height: self.tableView.rowHeight, width: view.frame.width,isBlock:false)
        case "following":
            let following = followingArray[indexPath.row]
            cell.init_userList(user_img:following.img_url, username:following.username, uid: following.uid, height: self.tableView.rowHeight, width: view.frame.width,isBlock:false)
        case "follower":
            let follower = followerArray[indexPath.row]
            cell.init_userList(user_img:follower.img_url, username:follower.username, uid: follower.uid, height: self.tableView.rowHeight, width: view.frame.width,isBlock:false)
        case "block":
            let block = blockArray[indexPath.row]
            cell.init_userList(user_img: block.img_url, username: block.username, uid: block.friend_uid, height: self.tableView.rowHeight, width: view.frame.width,isBlock:true)
        default: break
        }
        return cell
        
    }
    
    @IBAction func back(_ sender: Any) {
        //返回上一頁
        if from != "postGp"
        {
            (self.findTabBarController() as! MainTabBar).tabBar.isHidden = false
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func refresh()
    {
        callUserListService()
    }
}
