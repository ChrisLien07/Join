//
//  ProfileDetailView.swift
//  join
//
//  Created by ChrisLien on 2020/11/24.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ProfileDetailView: UIView {

    let lbl_name_gender_age = UILabel()
    let lbl_location = ProfileLabel(textColor: .white)
    let lbl_constellation = ProfileLabel(textAlignment: .center)
    let lbl_interest = ProfileLabel(textColor: .white)
      
    
    func initView(username: String,
                  gender: String,
                  age: String,
                  constellation_name: String,
                  constellation_id: String,
                  interest_name: String,
                  location_name: String)
    {
        setList(gender: gender, age: age, username: username, constellation_id: constellation_id, constellation_name: constellation_name, interest_name: interest_name, location_name: location_name)
        [lbl_name_gender_age,lbl_location,lbl_constellation,lbl_interest].forEach{ self.addSubview($0) }
        setupFrame()
    }
    
    func setList(gender: String, age: String, username: String, constellation_id: String, constellation_name: String, interest_name: String, location_name: String) {
        var tmpgender = ""
        if gender == "1" { tmpgender = "♂" } else if gender == "2" { tmpgender = "♀" }
        let attrbutedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.white])
        attrbutedText.append(NSMutableAttributedString(string: "   " + tmpgender, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.white]))
        attrbutedText.append(NSMutableAttributedString(string: "  " + String(age), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]))
        lbl_name_gender_age.attributedText = attrbutedText
        if constellation_name != "不透露" {
            lbl_constellation.addStartoLabel(img: UIImage(named: "constellation_\(constellation_id)")!, labelText: constellation_name)
        } else {
            lbl_constellation.text = ""
        }
        lbl_interest.text = interest_name.replacingOccurrences(of: ",", with: " / ")
        lbl_location.addIconToLabel(img: BasicIcons.place_48pt!, labelText: location_name, bounds_x: 0, bounds_y: -2, boundsWidth: 15, boundsHeight: 15)
    }
    
    func setupFrame() {
        lbl_name_gender_age.frame = CGRect(x: 16, y: 7, width:self.frame.width - 16, height: 30)
        lbl_location.frame = CGRect(x: 12, y: below(lbl_name_gender_age) + 5, width: 90, height: 18)
        lbl_constellation.frame = CGRect(x: lbl_location.frame.origin.x + 80, y: below(lbl_name_gender_age) + 5, width: 90, height: 18)
        lbl_interest.frame = CGRect(x: 15, y: below(lbl_constellation) + 10, width: self.frame.width, height: 18)
    }

}
