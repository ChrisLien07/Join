//
//  GpTableCell.swift
//  join
//
//  Created by 連亮涵 on 2020/6/17.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UserListTableCell: UITableViewCell {
    
    let v_Result = UIView()
    let user_Img = UIImageView()
    let lbl_username = UILabel()
    let lbl_unblock = UILabel()
    
    var uid: String = ""
   
    func init_userList(user_img: String,
                       username: String,
                       uid: String,
                       height: CGFloat,
                       width: CGFloat,
                       isBlock:Bool)
    {
        self.uid = uid
        v_Result.frame = CGRect(x:0,y:0,width: width,height: height)
        v_Result.backgroundColor = .white
        self.addSubview(v_Result)
        //設置圖片
        user_Img.frame = CGRect(x:10,y:5,width: height - 10 ,height: height - 10 )
        user_Img.contentMode = .scaleAspectFill
        user_Img.clipsToBounds = true
        user_Img.layer.cornerRadius = user_Img.frame.height / 2
        user_Img.isUserInteractionEnabled = true
        DownloadImage(view: user_Img, img: user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        let iconTap = UITapGestureRecognizer.init(target: self, action: #selector(showUser))
        user_Img.addGestureRecognizer(iconTap)
        v_Result.addSubview(user_Img)
        //設定文字
        lbl_username.frame = CGRect(x: user_Img.frame.origin.x + user_Img.frame.width + 10 ,y:height/2 - 10 , width: width ,height: 20)
        lbl_username.text = username
        lbl_username.font = .systemFont(ofSize: 18)
        lbl_username.textColor = UIColor.black
        v_Result.addSubview(lbl_username)
        if isBlock
        {
            let unblockAction = UITapGestureRecognizer.init(target: self, action: #selector(unblock))
            lbl_unblock.addGestureRecognizer(unblockAction)
            lbl_unblock.frame = CGRect(x: width - 80 ,y: (height - 25)/2 , width: 65 ,height: 25)
            lbl_unblock.text = "解除封鎖"
            lbl_unblock.textAlignment = .center
            lbl_unblock.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
            lbl_unblock.isUserInteractionEnabled = true
            lbl_unblock.font = .systemFont(ofSize: 14)
            lbl_unblock.textColor = Colors.rgb149Gray
            v_Result.addSubview(lbl_unblock)
        }
    }
    
    func CallUnblockService()
    {
        let request = createHttpRequest(Url: globalData.UnblockUserUrl, HttpType: "POST", Data: "token=\(globalData.token)&frienduid=\(self.uid)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBlock"), object: nil)
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.findViewController()?.present(vc, animated: true, completion: nil)
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
    
    @objc func unblock()
    {
        CallUnblockService()
    }
    
    @objc func showUser()
    {
        if let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC
        {
            userInfoVC.uid = uid
            self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
}
