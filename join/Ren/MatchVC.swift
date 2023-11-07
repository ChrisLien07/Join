//
//  MatchVC.swift
//  join
//
//  Created by ChrisLien on 2020/8/21.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MatchVC: UIViewController {

    @IBOutlet weak var img_self: UIImageView!
    @IBOutlet weak var img_matcher: UIImageView!
    @IBOutlet weak var btn_chat: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var img_like: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_text: UILabel!
    
    weak var delegate : Fri_Delegate?
    var ref: DatabaseReference!
    
    var matchInfo: MatchInfo = MatchInfo()
    var matchImgs: [String] = [String]()
    var isSuperLike = false
    var chtid = ""
    
    var imgSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgSize = (self.view.frame.width - 76)/2
        //
        ref = Database.database().reference()
        self.matchImgs = self.matchInfo.selectimg_url.components(separatedBy: ",")
        //
        lbl_title.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: 60)
        lbl_title.text = "配對成功"
        lbl_title.font = .italicSystemFont(ofSize: 27)
        //
        img_self.frame = CGRect(x: 38, y: lbl_title.frame.origin.y + lbl_title.frame.height + 40, width: imgSize, height: imgSize)
        img_self.contentMode = .scaleAspectFill
        img_self.layer.masksToBounds = true
        img_self.layer.cornerRadius = img_self.frame.height/2
        DownloadImage(view: img_self, img: globalData.user_img, id: "", placeholder: .none)
        //
        img_matcher.frame = CGRect(x: 38 + img_self.frame.width, y: lbl_title.frame.origin.y + lbl_title.frame.height + 40, width: imgSize, height: imgSize)
        img_matcher.contentMode = .scaleAspectFill
        img_matcher.layer.masksToBounds = true
        img_matcher.layer.cornerRadius = img_matcher.frame.height/2
        DownloadImage(view: img_matcher, img: matchImgs[0], id: "", placeholder: .none)
        //
        img_like.frame = CGRect(x: (38 + img_self.frame.width - 57/2), y: img_self.frame.origin.y + img_self.frame.height - 50, width: 57, height: 50)
        if isSuperLike {
            img_like.image = UIImage(named: "star-solid-74pt × 72pt")
        } else {
            img_like.image = UIImage(named: "heart-solid-79pt × 72pt")
        }
        //
        lbl_text.frame = CGRect(x: 0, y: img_self.frame.origin.y + imgSize + 15, width: self.view.frame.width, height: 30)
        lbl_text.font = .italicSystemFont(ofSize: 24)
        lbl_text.textAlignment = .center
        lbl_text.text = "你和\(matchInfo.selectusername)互有好感"
        //
        btn_chat.frame = CGRect(x: (self.view.frame.width/2) - 80 , y: lbl_text.frame.origin.y + lbl_text.frame.height + 70, width: 160, height: 40)
        btn_chat.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_chat.frame.height/2)
        btn_chat.layer.cornerRadius = btn_chat.frame.height/2
        //
        btn_back.frame = CGRect(x: (self.view.frame.width/2) - 80 , y: btn_chat.frame.origin.y + btn_chat.frame.height, width: 160, height: 40)
    }
    
    func callOpenChatService() {
        let request = createHttpRequest(Url: globalData.OpenChatUrl , HttpType: "POST", Data: "token=\(globalData.token)&frienduid=\(self.matchInfo.selectuid)")
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
                        self.chtid = responseJSON["chtid"] as! String
                        self.check()
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
    
    func check() {
        let userID = Auth.auth().currentUser?.uid
        var CID_array: [String] = [String]()
        //
        ref.child("chatroom_user").child(userID!).child("CID").observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
            if let CIDS = snapshot.value as? [String] {
                for CID in CIDS {
                    CID_array.append(CID)
                }
                
                if !CID_array.contains(self.chtid) {
                    CID_array.append(self.chtid)
                    self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
                }
            } else {
                CID_array.append(self.chtid)
                self.ref.child("chatroom_user").child(userID!).setValue(["CID": CID_array])
            }
            
            if let delegate = self.delegate {
                delegate.doSomethingWith(username: self.matchInfo.selectusername, img_url: self.matchInfo.selectimg_url, uid: self.matchInfo.selectuid, shortid: self.matchInfo.selectshortid, chtid: self.chtid)
            }
        }) { (error) in
            print("0")
        }
    }

    @IBAction func goChat(_ sender: Any) {
        callOpenChatService()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
}

protocol Fri_Delegate : NSObjectProtocol{
    func doSomethingWith(username: String, img_url: String,uid: String, shortid: String, chtid: String)
}
