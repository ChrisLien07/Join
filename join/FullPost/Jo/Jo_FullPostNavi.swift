//
//  Jo_FullPostNavi.swift
//  join
//
//  Created by 連亮涵 on 2020/6/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class Jo_FullPostNavi: UINavigationController,UINavigationControllerDelegate {
    
    var ptid: String = ""
    var uid: String = ""
    var isHit = ""
    var isExpired = false
    var scrolltoComt = false
    var cmtid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}
