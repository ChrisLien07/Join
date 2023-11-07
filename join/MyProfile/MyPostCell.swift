//
//  MyPostCell.swift
//  join
//
//  Created by 連亮涵 on 2020/7/31.
//  Copyright © 2020 gmpsykr. All rights reserved.
//
import UIKit

class MyPostCell: UITableViewCell {
    
    let v_main = UIView()
    let img_post = UIImageView()
    let lbl_text = UILabel()
    let lbl_gp = UILabel()
    let img_gp = UIImageView()
    let img_cmt_cnt = UIImageView()
    let lbl_cmt_cnt = UILabel()
    let img_delet = UIImageView()
    var pid = ""
    
    func initPost(pid: String,
                  uid: String,
                  img_url: String,
                  txt: String,
                  gp: String,
                  comt_cnt: String,
                  height: CGFloat,
                  width: CGFloat)
    {
        self.pid = pid
        self.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.postTouched(_:)))
        v_main.addGestureRecognizer(tap)
        //
        v_main.frame = CGRect(x:15 ,y:0 ,width: width ,height: height)
        v_main.setupShadow(offsetWidth: 5, offsetHeight: 5, opacity: 0.05, radius: 3)
        v_main.backgroundColor = .white
        v_main.layer.cornerRadius = v_main.frame.height/18
        self.addSubview(v_main)
        //設置圖片
        img_post.frame = CGRect(x:0, y:0, width: height, height: height)
        img_post.contentMode = .scaleAspectFill
        img_post.clipsToBounds = true
        if img_url.contains("/Video")
        {
            let tmpimg = img_url.replacingOccurrences(of: "/Video", with: "/Image")
            DownloadImage(view: img_post, img: tmpimg.replacingOccurrences(of: "mp4", with: "jpg"), id: "pid:" + pid, placeholder: nil)
        } else {
            DownloadImage(view: img_post, img: img_url, id: pid, placeholder: nil)
        }
        img_post.layer.cornerRadius = img_post.frame.height / 8
        v_main.addSubview(img_post)
        //設定文字
        lbl_text.frame = CGRect(x:height + 14 ,y: 14,width: width - 150,height: 50)
        lbl_text.text = txt
        lbl_text.font = .systemFont(ofSize: 15)
        lbl_text.numberOfLines = 2
        lbl_text.lineBreakMode = .byCharWrapping
        lbl_text.sizeToFit()
        v_main.addSubview(lbl_text)
        //設定讚數
        img_gp.frame = CGRect(x:img_post.frame.width + 14, y:img_post.frame.height - 25, width: 15, height: 15)
        img_gp.image = UIImage(named: "baseline_thumb_up_black_24pt")
        img_gp.tintColor = Colors.rgb149Gray
        v_main.addSubview(img_gp)
        lbl_gp.frame = CGRect(x: img_gp.frame.origin.x + img_gp.frame.width + 5 ,y:img_post.frame.height - 25 ,width: 20,height: 15)
        lbl_gp.text = gp
        lbl_gp.font = .systemFont(ofSize: 14)
        lbl_gp.textColor = Colors.rgb149Gray
        v_main.addSubview(lbl_gp)
        //設定留言數
        img_cmt_cnt.frame = CGRect(x: lbl_gp.frame.origin.x + lbl_gp.frame.width + 30 , y:img_post.frame.height - 25 , width: 15, height: 15)
        img_cmt_cnt.image = UIImage(named: "baseline_chat_bubble_black_24pt")
        img_cmt_cnt.tintColor = Colors.rgb149Gray
        v_main.addSubview(img_cmt_cnt)
        lbl_cmt_cnt.frame = CGRect(x: img_cmt_cnt.frame.origin.x + lbl_gp.frame.width + 5, y: img_post.frame.height - 25, width: 20,height: 15)
        lbl_cmt_cnt.text = comt_cnt
        lbl_cmt_cnt.font = .systemFont(ofSize: 14)
        lbl_cmt_cnt.textColor = Colors.rgb149Gray
        v_main.addSubview(lbl_cmt_cnt)
        //設定垃圾桶
        img_delet.frame = CGRect(x: width - 40 , y: img_post.frame.height - 30, width: 20,height: 20)
        img_delet.image = UIImage(named: "baseline_delete_black_24pt")
        img_delet.tintColor = Colors.themePurple
        let delet = UITapGestureRecognizer.init(target: self, action: #selector(deletePop))
        img_delet.addGestureRecognizer(delet)
        img_delet.isUserInteractionEnabled = true
        v_main.addSubview(img_delet)
    }
    
    @objc func deletePop()
    {
        let alertController = UIAlertController(title: "刪除貼文", message: "確定刪除貼文？刪除就無法恢復囉！", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default){(UIAlertAction) in
            self.callDeletePostService()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title:"再想想",style: .cancel)
        alertController.addAction(cancelAction)
        //顯示提示框
        self.findViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func callDeletePostService()
    {
        let request = createHttpRequest(Url: globalData.DeletePostUrl, HttpType: "POST", Data: "token=\(globalData.token)&pid=\(self.pid)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh_post"), object: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func postTouched(_ sender:UIGestureRecognizer){
        let Navi = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "Pi_FullPostNavi") as! Pi_FullPostNavi
        Navi.pid = pid
        self.findViewController()!.present(Navi, animated: true, completion: nil)
    }
}

