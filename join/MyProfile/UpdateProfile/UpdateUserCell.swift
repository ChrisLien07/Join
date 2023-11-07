//
//  UpdateUserCell.swift
//  join
//
//  Created by ChrisLien on 2020/10/26.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UpdateUserCell: UITableViewCell {

    let lbl_title = UILabel()
    
    let lbl_txt: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let img_next: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Colors.rgb149Gray
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: "baseline_keyboard_arrow_right_black_48pt")
        return iv
    }()
    
    var profile = UserInfo()
    var title = ""
    
    func init_profile(title: String,
                      profile: String,
                      width:CGFloat)
    {
        self.title = title
        let iconTap = UITapGestureRecognizer.init(target: self, action: #selector(change))
        addGestureRecognizer(iconTap)
        //
        [lbl_title,lbl_txt,img_next].forEach{ addSubview($0) }
        
        lbl_title.frame = CGRect(x:16,y:0,width: 100,height: 44)
        lbl_title.text = title
        lbl_title.font = .systemFont(ofSize: 16)
       
        img_next.frame = CGRect(x: width - 30, y: 13, width: 25, height: 25)
        lbl_txt.frame = CGRect(x: width - 190, y: 10, width: 150, height: 24)
        //
        switch title
        {
        case "興趣":
            
            img_next.frame = CGRect(x: width - 30, y: 26, width: 25, height: 25)
            lbl_txt.frame = CGRect(x: width - 190, y: 0, width: 150, height: 88)
            
            if globalData.tmpInterest.txt != "" {
                lbl_txt.text = globalData.tmpInterest.txt
            } else {
                lbl_txt.text = self.profile.interest_name
            }
        case "星座":
            if globalData.tmpConstellation.txt != "" {
                lbl_txt.text = globalData.tmpConstellation.txt
            } else {
                lbl_txt.text = self.profile.constellation_name
            }
        case "目前居住地":
            if globalData.tmpLocation.txt != "" {
                lbl_txt.text = globalData.tmpLocation.txt
            } else {
                lbl_txt.text = self.profile.location_name
            }
        case "職業":
            if globalData.tmpJob.txt != "" {
                lbl_txt.text = globalData.tmpJob.txt
            } else {
                lbl_txt.text = self.profile.job_name
            }
        case "血型":
            if globalData.tmpBloodtype.txt != "" {
                lbl_txt.text = globalData.tmpBloodtype.txt
            } else {
                if self.profile.bloodtype == "000" {
                    lbl_txt.text = "不透露"
                } else {
                    lbl_txt.text = self.profile.bloodtype
                }
            }
        case "個性":
            
            img_next.frame = CGRect(x: width - 30, y: 26, width: 25, height: 25)
            lbl_txt.frame = CGRect(x: width - 220, y: 0, width: 180, height: 88)
            
            if globalData.tmpPersonality.txt != "" {
                lbl_txt.text = globalData.tmpPersonality.txt
            } else {
                lbl_txt.text = self.profile.personality_name
            }
        case "尋找關係":
            if globalData.tmpRelationship.txt != "" {
                lbl_txt.text = globalData.tmpRelationship.txt
            } else {
                lbl_txt.text = self.profile.relationship_name
            }
        default:
            break
        }
    }
    
    @objc func change() {
        findViewController()?.endEdit()
        switch lbl_title.text {
        case "目前居住地":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "NewLocationVC") as! NewLocationVC
            vc.from = "update"
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "興趣":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "InterestVC") as! UserInterestsViewController
            vc.from = "update"
            vc.currentInterests = self.profile.interest_name_array
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "星座":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "InterestVC") as! UserInterestsViewController
            vc.isConstellation = true
            vc.from = "update"
            vc.currentConstellation = self.profile.constellation_name
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "職業":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UpdateListsVC") as! UpdateListsVC
            vc.from = "job"
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "血型":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UpdateListTbV") as! UpdateListTbV
            vc.from = "bloodtype"
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "個性":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UpdateListTbV") as! UpdateListTbV
            vc.from = "personality"
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        case "尋找關係":
            let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UpdateListsVC") as! UpdateListsVC
            vc.from = "relationship"
            self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

