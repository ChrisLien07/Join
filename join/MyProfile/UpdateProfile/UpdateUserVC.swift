//
//  UpdateUserVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/26.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class UpdateUserVC: UIViewController {

    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var cv_userPhoto: UICollectionView!
    @IBOutlet weak var tbv_list: UITableView!
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_birthday: UITextField!
    @IBOutlet weak var txt_userInfo: UITextView!
    @IBOutlet weak var v_gender: UIView!
    @IBOutlet weak var v_userInfo: UIView!
    @IBOutlet weak var lbl_gender: UILabel!
    
    let dp_picker = UIDatePicker()
    
    var photoArray: [String] = []
    var number_arr:[String] = ["1","2","3","4","5","6"]
    var titleArray: [String] = ["興趣","星座","目前居住地","職業","血型","個性","尋找關係"]
    var profile = UserInfo()
    var placehoalderText = "請輸入..."
    var constellation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的資訊"
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        view.addGestureRecognizer(tap)
        sv_main.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        [globalData.user_img,globalData.img_url2,globalData.img_url3,globalData.img_url4,globalData.img_url5,globalData.img_url6].forEach{ photoArray.append($0) }
        //
        cv_userPhoto.delegate = self
        cv_userPhoto.dataSource = self
        //
        txt_name.delegate = self
        txt_name.tag = 1
        txt_name.text = globalData.username
        txt_name.setPaddingPoints(20)
        txt_name.returnKeyType = .done
        txt_name.textAlignment = .right
        //
        txt_birthday.delegate = self
        txt_birthday.tag = 2
        txt_birthday.setPaddingPoints(20)
        txt_birthday.textAlignment = .right
        txt_birthday.inputView = dp_picker
        txt_birthday.setInputBirthdatePicker(target: self, selector: #selector(tapDone))
        if globalData.tmpBirthday != "" {
            txt_birthday.text = globalData.tmpBirthday
        } else {
            txt_birthday.text = globalData.birthday
        }
        //
        txt_userInfo.delegate = self
        txt_userInfo.isScrollEnabled = false
        if profile.user_info == "" {
            txt_userInfo.text = placehoalderText
            txt_userInfo.textColor = UIColor.black.withAlphaComponent(0.4)
        } else {
            txt_userInfo.text =  profile.user_info
            txt_userInfo.textColor = UIColor.black.withAlphaComponent(1)
        }
        //
        if globalData.gender == "1" {
            lbl_gender.text = "男"
        } else if globalData.gender == "2" {
            lbl_gender.text = "女"
        }
        //
        tbv_list.delegate = self
        tbv_list.dataSource = self
        tbv_list.frame.size.height = 44*9
        sv_main.contentSize.height = tbv_list.frame.origin.y + tbv_list.frame.height
        collectionViewLayout()
    }
    
    func callUpdateUserService()
    {
        var data: String = "token=\(globalData.token)&username=\(txt_name.text!)&birthdate=\(txt_birthday.text!)&user_info=\(globalData.tmpUserInfo)&personality=\(globalData.tmpPersonality.id)&constellation=\(globalData.tmpConstellation.id)&location=\(globalData.tmpLocation.id)&job=\(globalData.tmpJob.id)&bloodtype=\(globalData.tmpBloodtype.txt)&interest=\(globalData.tmpInterest.id)&relationship=\(globalData.tmpRelationship.id)"
        
        if txt_name.text == "" {
            let endIndex = data.range(of: "&username=\(txt_name.text!)")
            data.removeSubrange(endIndex!)
        }
        if txt_birthday.text == "" {
            let endIndex = data.range(of: "&birthdate=\(txt_birthday.text!)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpUserInfo == "" {
            let endIndex = data.range(of: "&user_info=\(globalData.tmpUserInfo)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpPersonality.id == "" {
            let endIndex = data.range(of: "&personality=\(globalData.tmpPersonality.id)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpConstellation.id == "" {
            let endIndex = data.range(of: "&constellation=\(globalData.tmpConstellation.id)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpLocation.id == "" {
            let endIndex = data.range(of: "&location=\(globalData.tmpLocation.id)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpJob.id == "" {
            let endIndex = data.range(of: "&job=\(globalData.tmpJob.id)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpBloodtype.txt == "" {
            let endIndex = data.range(of: "&bloodtype=\(globalData.tmpBloodtype.txt)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpInterest.id == "" {
            let endIndex = data.range(of: "&interest=\(globalData.tmpInterest.id)")
            data.removeSubrange(endIndex!)
        }
        if globalData.tmpRelationship.id == "" {
            let endIndex = data.range(of: "&relationship=\(globalData.tmpRelationship.id)")
            data.removeSubrange(endIndex!)
        }
        let request = createHttpRequest(Url: globalData.UpdateUserUrl, HttpType: "POST", Data: data)
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
                        shortInfoMsg(msg: "更改完成", vc: self,sec: 2) {
                            NotificationCenter.default.post(name: Notifications.queryUser, object: nil)
                            self.showMainBar()
                            clearTmpData()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        shortInfoMsg(msg: "更改成功", vc: self,sec: 2)
                        {
                            self.showMainBar()
                            clearTmpData()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkName(name:String) -> Bool {
        let pattern = "[^a-zA-Z一-龥]"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: name, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, name.count))
        if res.count > 0{return false}
        else{return true}
    }
    
    @objc func tapDone() {
        if let datePicker = self.txt_birthday.inputView as? UIDatePicker
        {
            let dateformatter = DateFormatter()
            let today = NSDate()
             dateformatter.dateFormat = "yyyy-MM-dd"
            let dateOfBirth = datePicker.date
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let age = gregorian.components([.year], from: dateOfBirth, to: today as Date, options: [])
           
            self.txt_birthday.text = dateformatter.string(from: datePicker.date)
            if age.year! < 18 {
                txt_birthday.text = globalData.birthday
                shortInfoMsg(msg: "年齡須滿18歲", vc: self.findViewController()!, sec: 2)
            }
        }
        txt_birthday.resignFirstResponder()
    }

    @objc func refresh() {
        tbv_list.reloadData()
    }

    func collectionViewLayout() {
        let flowLayout = UICollectionViewLeftAlignedLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 20.0, left: 50, bottom: 20, right: 50)
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 25
        flowLayout.itemSize = CGSize(width: self.view.frame.width*0.19, height: self.view.frame.width*0.19)
        cv_userPhoto.collectionViewLayout = flowLayout
    }
    
    @IBAction func send(_ sender: Any) {
        if(!checkName(name: txt_name.text!)) {
            ShowErrMsg(code: 0, msg: "暱稱限用中英字母", vc: self.findViewController()!)
            return
        }
        callUpdateUserService()
    }
    
    @IBAction func back(_ sender: Any) {
        if txt_name.text != "" || txt_birthday.text != "" || globalData.tmpUserInfo != "" || globalData.tmpPersonality.id != "" || globalData.tmpConstellation.id != "" || globalData.tmpLocation.id != "" || globalData.tmpJob.id != "" || globalData.tmpBloodtype.txt != "" || globalData.tmpInterest.id != "" || globalData.tmpRelationship.id != "" {
            let alertController = UIAlertController(title: nil, message: "請問您要放棄目前編輯的資訊？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default,handler: {(_) in
                (self.findTabBarController() as! MainTabBar).tabBar.isHidden = false
                clearTmpData()
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(okAction)
            alertController.addAction(UIAlertAction(title:"取消",style: .cancel))
            //顯示提示框
            present(alertController, animated: true, completion: nil)
        } else {
            showMainBar()
            clearTmpData()
            navigationController?.popViewController(animated: true)
        }
    }
}

extension UpdateUserVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 1:
            guard let textFieldText = textField.text,
                   let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                       return false
               }
               let substringToReplace = textFieldText[rangeOfTextToReplace]
               let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 20
        case 2 :
            return false
        default:
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        globalData.tmpName = txt_name.text!
        txt_name.resignFirstResponder()
        return true
    }
}

extension UpdateUserVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 || indexPath.row == 0 {
            return 88
        } else {
            return 44
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateUserCell", for: indexPath) as! UpdateUserCell
        let list = titleArray[indexPath.row]
        cell.profile = self.profile
        cell.init_profile(title: list, profile:profile.user_info, width: view.frame.width)
        return cell
    }
}
extension UpdateUserVC: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "NewUpdateImageCell", for: indexPath) as! UpdateImageCell
        let photo = photoArray[indexPath.row]
        let num = number_arr[indexPath.row]
        cell.init_photo(img_url:photo, size: self.view.frame.width*0.19, num: num)
        return cell
    }
}

extension UpdateUserVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        globalData.tmpUserInfo = txt_userInfo.text!
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 100
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        //開始編輯後去除placeholder
        if  textView.textColor == UIColor.black.withAlphaComponent(0.4) {
            textView.text = ""
            textView.textColor = UIColor.black.withAlphaComponent(1)
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        globalData.tmpUserInfo = txt_userInfo.text!
        //結束編輯後依字數生成placeholder
        if  !textView.hasText {
            textView.text = placehoalderText
            textView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}
