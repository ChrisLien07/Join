//
//  UserInterestsViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UICollectionViewLeftAlignedLayout

class UserInterestsViewController: UIViewController {
    
    @IBOutlet weak var cv_interest: UICollectionView!
    @IBOutlet weak var lbl_warning: UILabel!
    
    var v_Interest = UIView()
    var interest_combineArr = [Combine]()
    let interest_titleArray : [String] = ["遊戲","旅遊","電影","素食","小吃","咖啡","下廚","健身","寵物","露營","攝影","汽車"]
    let interest_idArray : [String] = ["001","002","003","004","005","006","007","008","009","010","011","012"]
    var constellation_combineArr = [Combine]()
    let constellation_titleArray:[String] = ["牡羊座","金牛座","雙子座","巨蠍座","獅子座","處女座","天秤座","天蠍座","射手座","摩羯座","水瓶座","雙魚座"]
    let constellation_idArray:[String] = ["001","002","003","004","005","006","007","008","009","010","011","012"]

    var from = ""
    var isConstellation = false
    var currentConstellation = ""
    var currentInterests:[String] = []
    var cvItemSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        cv_interest.delegate = self
        cv_interest.dataSource = self
        constellation_combineArr = combineArray(idArr: constellation_idArray, txtArr: constellation_titleArray)
        interest_combineArr = combineArray(idArr: interest_idArray, txtArr: interest_titleArray)
        if isConstellation {
            cv_interest.allowsMultipleSelection = false
        } else {
            cv_interest.allowsMultipleSelection = true
        }
        //
        if from == "update" {
            navigationItem.rightBarButtonItem = .none
            if isConstellation {
                title = "我的星座"
                lbl_warning.isHidden = true
            } else {
                title = "我的興趣"
            }
        }
        
        lbl_warning.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 15, left: 22, bottom: 0, right: 0), size: CGSize(width: 0, height: 20))
        cv_interest.anchor(top: lbl_warning.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 26, left: 0, bottom: 0, right: 0))
        
        cvItemSize = CGFloat(view.frame.width*0.27)
        collectionViewLayout()
    }
    
    func callSignUpService() {
        var interestIdArray : [String] = ["","","","","","",""]
        if cv_interest.indexPathsForSelectedItems!.count > 0
        {
            for i in 0...(cv_interest.indexPathsForSelectedItems!.count - 1) {
                interestIdArray[i] = interest_combineArr[cv_interest.indexPathsForSelectedItems![i].item].id
            }
        }
        var tmpInterest = ""
        for i in 0...interestIdArray.count - 1
        {
            if interestIdArray[i] != "" {
                tmpInterest.append("," + interestIdArray[i])
            }
        }
        if tmpInterest != "" {
            tmpInterest.removeFirst()
            
        }
        globalData.interest = tmpInterest
        
        if let user = Auth.auth().currentUser
        {
            globalData.uid = user.uid
            let request = createHttpRequest(Url: globalData.SignUpUserUrl, HttpType: "POST", Data: "&firebase_uid=\(globalData.uid)&phonenum=\(globalData.serverPhonenum)&username=\(globalData.username)&gender=\(globalData.gender)&birthdate=\(globalData.birthday)&location=\(globalData.location)&interest=\(globalData.interest)&img_url=\(globalData.user_img)&source=\("ios")")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else
                {
                    Alert.ShowConnectErrMsg(vc: self)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]
                {
                    DispatchQueue.main.async
                    {
                        if responseJSON["code"] as! Int == 0
                        {
                            if let info = responseJSON["user"] as? [String: Any]
                            {
                                globalData.token = info["token"] as! String
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismiss"), object: nil)
                            }
                        }
                        else
                        {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                            self.navigationItem.rightBarButtonItem!.isEnabled = true
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func collectionViewLayout() {
        let flowLayout = UICollectionViewLeftAlignedLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = (view.frame.width - (cvItemSize*3) - 40)/2
        flowLayout.itemSize = CGSize(width: cvItemSize, height: cvItemSize)
        cv_interest.collectionViewLayout = flowLayout
    }

    @IBAction func upload(_ sender: Any) {
        if cv_interest.indexPathsForSelectedItems?.count ?? 0 > 0 {
            self.navigationItem.rightBarButtonItem!.isEnabled = false
            callSignUpService()
        } else {
            shortInfoMsg(msg: "請至少選擇一項", vc: self, sec: 2)
        }
    }
    
    @IBAction func back() {
        if from == "update" {
            if isConstellation {
                if cv_interest.indexPathsForSelectedItems?.count ?? 0 > 0 {
                    globalData.tmpConstellation = constellation_combineArr[cv_interest.indexPathsForSelectedItems![0].item]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                }
            } else {
                if cv_interest.indexPathsForSelectedItems?.count ?? 0 > 0 {
                    var idArray: [String] = []
                    var txtArray: [String] = []
                    
                    for i in 0...(cv_interest.indexPathsForSelectedItems!.count - 1) {
                        idArray.append(interest_combineArr[cv_interest.indexPathsForSelectedItems![i].item].id)
                        txtArray.append(interest_combineArr[cv_interest.indexPathsForSelectedItems![i].item].txt)
                    }
                
                    globalData.tmpInterest.id =  idArray.joined(separator: ",")
                    globalData.tmpInterest.txt = txtArray.joined(separator: ",")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

extension UserInterestsViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "InterestsCell", for: indexPath) as! InterestsViewCell
        if isConstellation
        {
            let title = constellation_combineArr[indexPath.row].txt
            let pic = globalData.constellation_pic_array[indexPath.row]
            cell.init_View(pic:pic ,title:title, width:cvItemSize)
            if globalData.tmpConstellation.txt != ""
            {
                if self.constellation_combineArr.contains(where: { $0.txt == globalData.tmpConstellation.txt}) {
                    let tmp =  constellation_combineArr.filter(){$0.txt == globalData.tmpConstellation.txt}
                    let tmpInt = Int(tmp[0].id)! - 1
                    let selectedIndexPath = IndexPath(item: tmpInt, section: 0)
                    cv_interest.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
                    cv_interest.delegate!.collectionView!(cv_interest, didSelectItemAt: selectedIndexPath)
                }
            }
            else
            {
                if self.constellation_combineArr.contains(where: { $0.txt == self.currentConstellation}) {
                    let tmp =  constellation_combineArr.filter(){$0.txt == self.currentConstellation}
                    let tmpInt = Int(tmp[0].id)! - 1
                    let selectedIndexPath = IndexPath(item: tmpInt, section: 0)
                    cv_interest.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
                    cv_interest.delegate!.collectionView!(cv_interest, didSelectItemAt: selectedIndexPath)
                }
            }
        }
        else
        {
            let title = interest_combineArr[indexPath.row].txt
            let pic = globalData.interest_pic_array[indexPath.row]
            cell.init_View(pic:pic ,title:title, width:cvItemSize)
            
            if globalData.tmpInterest.txt != ""
            {
                let tmpArry = globalData.tmpInterest.txt.components(separatedBy: ",")
                for i in tmpArry
                {
                    if self.interest_combineArr.contains(where: { $0.txt == i}) {
                        let tmp =  interest_combineArr.filter(){$0.txt == i}
                        let tmpInt = Int(tmp[0].id)! - 1
                        let selectedIndexPath = IndexPath(item: tmpInt, section: 0)
                        cv_interest.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
                        cv_interest.delegate!.collectionView!(cv_interest, didSelectItemAt: selectedIndexPath)
                    }
                }
            }
            else
            {
                for i in currentInterests
                {
                    if self.interest_combineArr.contains(where: { $0.txt == i}) {
                        let tmp =  interest_combineArr.filter(){$0.txt == i}
                        let tmpInt = Int(tmp[0].id)! - 1
                        let selectedIndexPath = IndexPath(item: tmpInt, section: 0)
                        cv_interest.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
                        cv_interest.delegate!.collectionView!(cv_interest, didSelectItemAt: selectedIndexPath)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isConstellation {
            if let cell = collectionView.cellForItem(at: indexPath) as? InterestsViewCell {
                cell.setSelected()
            }
        }
        else {
            if collectionView.indexPathsForSelectedItems!.count <= 6 {
                if let cell = collectionView.cellForItem(at: indexPath) as? InterestsViewCell {
                    cell.setSelected()
                }
            }
            else {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? InterestsViewCell {
            cell.setDeselected()
        }
    }
    
}
