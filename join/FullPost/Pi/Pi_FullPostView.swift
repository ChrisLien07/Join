//
//  Pi_FullPostView.swift
//  join
//
//  Created by 連亮涵 on 2020/6/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Agrume
import AVFoundation
import AVKit

class Pi_FullPostView: UIView {
      
    let v_post = UIView()
    let lbl_username = UILabel()
    let img_userIcon = UIImageView()
    let lbl_PostTime = UILabel()
    let txt_PostText = UITextView()
    let sv_Images = UIScrollView()
    let lbl_GoodNum = UILabel()
    let lbl_CommandNum = UILabel()
    let v_Line = UIView()
    let btn_good = UIButton()
    let v_buttons = UIView()
    let v_BottomLine = UIView()
    let avPlayerVC = AVPlayerViewController()
    var avplayerArray = [AVPlayer]()
    var videoCount = 0
    var isGood = false
    var gp: String = ""
    var pid: String = ""
    var uid: String = ""
    var comt_cnt : String = ""
    var parentVC: Pi_FullPostVC?
        
    func setPostData(username: String,
                     user_img: String,
                     posttime: String,
                     text: String,
                     img_url: String,
                     gp: String,
                     comt_cnt: String,
                     width: CGFloat,
                     pid:String,
                     uid:String,
                     isGood: Bool)
    {
        self.gp = gp
        self.pid = pid
        self.uid = uid
        self.isGood = isGood
        self.comt_cnt = comt_cnt
        let imgs:[String] = img_url.components(separatedBy: ",")
        self.frame = CGRect(x:0,y:0,width: width,height: 420)
        self.backgroundColor = .white
        //設定主要貼文區域
        v_post.frame = CGRect(x:0,y:0,width: width,height: 360)
        self.addSubview(v_post)
        //設定頭像
        img_userIcon.frame = CGRect(x:20,y:15,width: 50,height: 50)
        img_userIcon.configureUserIcon(target: self, cornerRadious: 25, selector: #selector(showUser))
        DownloadImage(view: img_userIcon, img: user_img, id: "uid:" + uid,placeholder: UIImage(named: "user.png"))
        v_post.addSubview(img_userIcon)
        //設定暱稱
        lbl_username.frame = CGRect(x:80,y:20,width: 200,height: 20)
        lbl_username.text = username
        lbl_username.font = .boldSystemFont(ofSize: 18)
        lbl_username.textColor = UIColor.black.withAlphaComponent(0.75)
        v_post.addSubview(lbl_username)
        //設定時間
        lbl_PostTime.frame = CGRect(x:80,y:40,width: 200,height: 20)
        lbl_PostTime.text = posttime
        lbl_PostTime.textAlignment = .natural
        lbl_PostTime.font = .systemFont(ofSize: 14)
        lbl_PostTime.textColor = Colors.rgb149Gray
        v_post.addSubview(lbl_PostTime)
        //設定文字
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        txt_PostText.frame = CGRect(x:20,y:80,width: width - 40,height: 60)
        txt_PostText.attributedText = NSAttributedString(string: text, attributes:attributes)
        txt_PostText.textAlignment = .natural
        txt_PostText.font = .systemFont(ofSize: 15)
        txt_PostText.textContainerInset = .zero
        txt_PostText.textContainer.lineFragmentPadding = 0
        txt_PostText.textColor = UIColor.black.withAlphaComponent(0.75)
        txt_PostText.translatesAutoresizingMaskIntoConstraints = true
        txt_PostText.sizeToFit()
        txt_PostText.isScrollEnabled = false
        txt_PostText.isEditable = false
        v_post.addSubview(txt_PostText)
        //
        lbl_GoodNum.isUserInteractionEnabled = true
        let tapGp = UITapGestureRecognizer.init(target: self, action: #selector(goGpPage))
        lbl_GoodNum.addGestureRecognizer(tapGp)
        //設定圖片
        sv_Images.frame = CGRect(x:0, y:txt_PostText.frame.origin.y + txt_PostText.frame.height+10, width: width, height: width)
        sv_Images.contentSize = CGSize(width: width * CGFloat(imgs.count), height: width)
        sv_Images.isScrollEnabled = true
        sv_Images.isPagingEnabled = true
        sv_Images.showsHorizontalScrollIndicator = false
        var imgCount = 0
        if imgs.count == 0 || imgs[0] == "" {
          sv_Images.frame.size.height = 20
          v_Line.frame = CGRect(x:0,y:19,width: width,height: 0.5)
          v_Line.backgroundColor = .lightGray
          sv_Images.addSubview(v_Line)
        }
        for img in imgs
        {
            let imgView = UIImageView()
            imgView.frame = CGRect(x:width * CGFloat(imgCount),y:0,width: width,height: width)
            imgView.contentMode = .scaleAspectFill
            imgView.layer.masksToBounds = true
            imgView.isUserInteractionEnabled = true
            sv_Images.addSubview(imgView)
            if img.contains("/Video") {
                let tmpimg = img.replacingOccurrences(of: "/Video", with: "/Image")
                DownloadImage(view: imgView, img: tmpimg.replacingOccurrences(of: "mp4", with: "jpg"), id: "pid:" + pid, placeholder: nil)
                let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
                imgView.addGestureRecognizer(tap)
                DownloadVideo(path: img,view: imgView)
            } else {
                let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                imgView.addGestureRecognizer(tap)
                DownloadImage(view: imgView, img: img, id: "pid:" + pid, placeholder: nil)
            }
                  
            imgCount += 1

            if (imgs.count > 1)
            {
                let lbl_Count = UILabel()
                lbl_Count.frame = CGRect(x: imgView.frame.origin.x + width-55,y: 5,width: 50,height: 35)
                lbl_Count.text = "\(imgCount)/\(imgs.count)"
                lbl_Count.font = .boldSystemFont(ofSize: 17)
                lbl_Count.textAlignment = .center
                lbl_Count.backgroundColor = .black
                lbl_Count.textColor = .white
                lbl_Count.alpha = 0.8
                lbl_Count.layer.cornerRadius = 10
                lbl_Count.layer.masksToBounds = true
                sv_Images.addSubview(lbl_Count)
            }
        }
        v_post.addSubview(sv_Images)

        setGoodNum()
          
        //設定留言數
        lbl_CommandNum.frame = CGRect(x:90,y:lbl_GoodNum.frame.origin.y,width: 85,height: 20)
        lbl_CommandNum.text = String(comt_cnt) + "則留言"
        lbl_CommandNum.textAlignment = .left
        lbl_CommandNum.font = .systemFont(ofSize: 15)
        lbl_CommandNum.textColor = UIColor.black.withAlphaComponent(0.4)
        v_post.addSubview(lbl_CommandNum)
        //設定按鈕
        setGoodButton(width: width)
        //分隔線
        v_BottomLine.frame = CGRect(x:0,y:sv_Images.frame.origin.y + sv_Images.frame.height + 49.5,width: width,height: 0.5)
        v_BottomLine.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v_post.addSubview(v_BottomLine)
        //重新設定高度
        self.frame = CGRect(x: 0,y: 0,width: width,height: v_BottomLine.frame.origin.y + 0.5)
        v_post.frame = CGRect(x: 0,y: 0,width: width,height: self.frame.height)
    }
      
    func setGoodNum()
    {
        //設定讚數
        lbl_GoodNum.frame = CGRect(x:20,y:sv_Images.frame.origin.y + sv_Images.frame.height + 15,width: 70,height: 20)
        lbl_GoodNum.text = gp + "個讚"
        lbl_GoodNum.textAlignment = .left
        lbl_GoodNum.font = .systemFont(ofSize: 15)
        lbl_GoodNum.textColor = UIColor.black.withAlphaComponent(0.4)
        v_post.addSubview(lbl_GoodNum)
    }
      
    func setGoodButton(width: CGFloat)
    {
        btn_good.frame.size = CGSize(width: 50,height: 50)
        btn_good.center = CGPoint(x: width - 60,y: sv_Images.frame.origin.y + sv_Images.frame.height)
        btn_good.setImage(UIImage.init(named: "baseline_thumb_up_black_24pt"), for: .normal)
        btn_good.imageView?.tintColor = isGood ? Colors.themePurple : .lightGray
        btn_good.backgroundColor = .white
        btn_good.layer.cornerRadius = btn_good.frame.height / 2
        btn_good.setupShadow(offsetWidth: 0, offsetHeight: 1, opacity: 0.7, radius: 3)
        btn_good.layer.shadowColor = UIColor.gray.cgColor
        btn_good.addTarget(self, action: #selector(callGoodService), for: .touchUpInside)
        v_post.addSubview(btn_good)
    }
      
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let imageView = sender.view as! UIImageView
        let img = imageView.image
        if img != nil
        {
            let agrume = Agrume(image: img!, background: .blurred(.dark), dismissal: .withButton(.none))
            let vc = self.findViewController() as! Pi_FullPostVC
            vc.txt_Input.resignFirstResponder()
            agrume.show(from: vc)
        }
    }
      
    @objc func callGoodService()
    {
        btn_good.isEnabled = false
        var tmp : Int?
        if isGood {
            tmp = 0
        } else {
            tmp = 1
        }
        let request = createHttpRequest(Url: globalData.SetGpUrl, HttpType: "POST", Data: "token=\(globalData.token)&pid=\(pid)&isGp=\(tmp!)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                self.btn_good.isEnabled = true
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        self.isGood = !self.isGood
                        self.btn_good.setTitleColor(self.isGood ? Colors.themePurple : .lightGray, for: .normal)
                        self.btn_good.imageView?.tintColor = self.isGood ? Colors.themePurple : .lightGray
                        self.btn_good.tintColor = self.isGood ? Colors.themePurple : .lightGray
                        var goodNum : Int = Int(self.gp)!
                        goodNum += self.isGood ? 1 : -1
                        self.gp = String(goodNum)
                        (self.findViewController() as! Pi_FullPostVC).fullPost.gp += String(goodNum)
                        self.lbl_GoodNum.text = self.gp + "個讚"
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
                    self.btn_good.isEnabled = true
                }
            }
        }
        task.resume()
    }
      
    func DownloadVideo(path: String,view:UIImageView)
    {
        var avPlayer:AVPlayer? = nil
        let url = URL(string: path)!
        avPlayer = AVPlayer(url: url)
        self.avplayerArray.append(avPlayer!)
        view.tag = self.videoCount
        self.videoCount += 1
    }
      
    @objc func playVideo(_ sender: UITapGestureRecognizer)
    {
        parentVC?.endEdit()
        self.findViewController()?.present(avPlayerVC, animated: true)
        {
            self.avPlayerVC.player = self.avplayerArray[sender.view!.tag]
            self.avPlayerVC.player?.play()
        }
    }
      
    @objc func goGpPage() {
        let vc = self.findViewController()!.storyboard?.instantiateViewController(withIdentifier: "UserListCell") as! UserListTableVC
        vc.pid = pid
        vc.from = "postGp"
        self.findViewController()!.navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func showUser() {
        (findViewController() as! Pi_FullPostVC).endEdit()
        let userInfoVC = self.findViewController()?.storyboard!.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        userInfoVC.uid = uid
        self.findViewController()?.navigationController?.pushViewController(userInfoVC, animated: true)
    }
}

