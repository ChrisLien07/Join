//
//  MyPostTbV.swift
//  join
//
//  Created by 連亮涵 on 2020/7/31.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import MJRefresh

class MyPostTbV: UITableViewController {

    var myPostArray: [Post] = []
    var historyPostArray: [Post] = []
    
    let rc_head = MJRefreshNormalHeader()
    let rc_foot = MJRefreshAutoFooter()
    
    var pageCount: Int = 0
    var postEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh_post"), object: nil)
        setupMJRefresh()
        callMyPostService(block: 0, refresh: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "我的貼文"
        hideMainBar()
    }
    
    func setupMJRefresh() {
        rc_head.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        self.tableView.mj_header = rc_head
        rc_foot.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        self.tableView.mj_footer = rc_foot
    }
    
    func callMyPostService(block: Int, refresh: Bool){
        
        let request = createHttpRequest(Url: globalData.GetPostListUrl, HttpType: "POST", Data: "token=\(globalData.token)&block=\(pageCount)&type=\("2")")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                DispatchQueue.main.async {
                    self.tableView.mj_header!.endRefreshing()
                    self.tableView.mj_footer!.endRefreshing()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        if refresh {
                            self.myPostArray.removeAll()
                        }
                        for po in responseJSON["list"] as! [[String: Any]] {
                            let tmpPost = Post()
                            parsePosts(post: tmpPost, po: po)
                            self.myPostArray.append(tmpPost)
                        }
                        self.pageCount += 1
                        self.tableView.reloadData()
                    }
                    else if responseJSON["code"] as! Int == 127
                    {
                        self.postEnd = true
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                    self.tableView.mj_header!.endRefreshing()
                    self.tableView.mj_footer!.endRefreshing()
                }
            }
        }
        task.resume()
    }
    
    @objc func refresh() {
        pageCount = 0
        postEnd = false
        self.callMyPostService(block: 0, refresh: true)
    }
    
    @objc func loadmore() {
        if !postEnd {
            callMyPostService(block: pageCount, refresh: false)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCell", for: indexPath) as! MyPostCell
        let post = myPostArray[indexPath.row]
        cell.selectionStyle = .none
        cell.initPost(pid: post.pid, uid: post.uid, img_url: post.img_url, txt: post.text, gp: post.gp, comt_cnt: post.comt_cnt, height: view.frame.height/9, width:view.frame.width - 30)
        if indexPath.row == 0 {
            cell.v_main.frame = CGRect(x:15,y:15,width: view.frame.width - 30,height: view.frame.height/9)
        }
      
        cell.img_post.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        return cell
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.height/9 + 30
        } else {
            return view.frame.height/9 + 15
        }
    }
}
