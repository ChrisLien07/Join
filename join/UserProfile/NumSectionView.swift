//
//  NumSectionView.swift
//  join
//
//  Created by ChrisLien on 2020/11/24.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class NumSectionView: UIView {
    
    let lbl_party_cnt = NumberLabel()
    let lbl_like_cnt = NumberLabel()
    let lbl_follower_cnt = NumberLabel()
    let lbl_follow_cnt = NumberLabel()
      
    
    func initView(party_cnt: String,
                  like_cnt: String,
                  follower_cnt: String,
                  follow_cnt: String)
    {
        setList(party_cnt: party_cnt, like_cnt: like_cnt, follower_cnt: follower_cnt, follow_cnt: follow_cnt)
        [lbl_party_cnt,lbl_like_cnt,lbl_follower_cnt,lbl_follow_cnt].forEach { self.addSubview($0) }
        setupFrame()
    }
    
    func setList(party_cnt: String, like_cnt: String, follower_cnt: String, follow_cnt: String) {
        lbl_party_cnt.makeLable(string1: party_cnt, string2: "\n聚會")
        lbl_like_cnt.makeLable(string1: like_cnt, string2: "\n人氣")
        lbl_follower_cnt.makeLable(string1: follower_cnt, string2: "\n粉絲人數")
        lbl_follow_cnt.makeLable(string1: follow_cnt, string2: "\n追蹤中")
    }
    
    func setupFrame() {
        lbl_party_cnt.frame = CGRect(x: (self.frame.width - 320)/2 , y: 0, width: 80, height: self.frame.width*0.15)
        lbl_like_cnt.frame = CGRect(x: after(lbl_party_cnt), y: 0, width: 70, height:  self.frame.width*0.15)
        lbl_follower_cnt.frame = CGRect(x: after(lbl_like_cnt), y: 0, width:90, height:  self.frame.width*0.15)
        lbl_follow_cnt.frame = CGRect(x: after(lbl_follower_cnt), y: 0, width: 80, height:  self.frame.width*0.15)
    }
}
