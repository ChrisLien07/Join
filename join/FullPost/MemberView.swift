//
//  MemberView.swift
//  join
//
//  Created by ChrisLien on 2020/11/30.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class MemberView: UIView {
    
    let lbl_host: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.text = "主辦人"
        return lbl
    }()
    
    let lbl_member: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.text = "參加者"
        return lbl
    }()
    
    let lbl_username: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 16)
        return lbl
    }()
    
    let img_userIcon: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 22.5
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
        
    }()
    
    lazy var cv_member: UICollectionView = {
        
        let flowLayout = UICollectionViewLeftAlignedLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 26
        flowLayout.minimumLineSpacing = 20
        flowLayout.itemSize = CGSize(width: (width - 140)/5, height: 70)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.register(MemberViewCell.self, forCellWithReuseIdentifier: "MemberCell")
        return cv
    }()
    
    let v_line = UIView()
    
    var participant_arry: [AttendanceList] = []
    var width: CGFloat = 0
    
    func init_view(hostName: String,
                   hostIcon: String,
                   ptid: String,
                   uid: String,
                   attendance: Int,
                   width: CGFloat)
    {
        self.width = width
        [lbl_host, img_userIcon, lbl_username, lbl_member, cv_member, v_line].forEach { addSubview($0) }
        setupFrames(attendance: attendance,width: width)
        frame.size = CGSize(width: width, height: cv_member.frame.origin.y + cv_member.frame.height)
        setupSubViews(name: hostName, icon: hostIcon, uid: uid)
        getAttendanceList(ptid: ptid, hostName: hostName, hostIcon: hostIcon, uid: uid)
    }
    
    func getAttendanceList(ptid : String, hostName: String, hostIcon: String, uid: String) {
        NetworkManager.shared.callGetAttendListService(ptid: ptid) { [self] (code, list, msg) in
            
            participant_arry.removeAll()
    
            switch code {
            case 0:
                participant_arry = list!
                
                let tmpUsername = participant_arry.filter( { $0.uid == uid } )
                lbl_username.text = tmpUsername.first?.username
                
                participant_arry = participant_arry.filter({$0.username != hostName})
                
                cv_member.reloadData()
            case 2:
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
            case 127:
                
                let tmpUsername = participant_arry.filter( { $0.uid == uid } )
                lbl_username.text = tmpUsername.first?.username

                cv_member.reloadData()
            default:
                ShowErrMsg(code: code, msg: msg!, vc: findViewController()!)
            }
        }
    }
    
    func setupSubViews(name: String, icon: String, uid: String) {
        DownloadImage(view: img_userIcon, img: icon, id: "uid:" + uid, placeholder: nil)
        //lbl_username.text = name
        v_line.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    func setupFrames(attendance: Int, width: CGFloat) {
        lbl_host.frame = CGRect(x: 18, y: 0, width: 100, height: 22)
        img_userIcon.frame = CGRect(x: 18, y: below(lbl_host) + 10, width: 45, height: 45)
        lbl_username.frame = CGRect(x: 18 + 45 + 18, y: below(lbl_host) + 21, width: width - 85, height: 22)
        lbl_member.frame = CGRect(x: 18, y: below(img_userIcon) + 18, width: 100, height: 22)
        if  attendance > 5 {
            cv_member.frame = CGRect(x: 18, y: below(lbl_member) + 10, width: width - 36, height: 160)
        } else {
            cv_member.frame = CGRect(x: 18, y: below(lbl_member) + 10, width: width - 36, height: 80)
        }
        v_line.frame = CGRect(x:0,y: below(cv_member), width: width ,height: 0.5)
    }
}

extension MemberView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participant_arry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell (withReuseIdentifier: "MemberCell", for: indexPath) as! MemberViewCell
        let member = participant_arry[indexPath.row]
        cell.init_cell(username: member.username, img_url: member.img_url, uid: member.uid)
        return cell
    }
}
