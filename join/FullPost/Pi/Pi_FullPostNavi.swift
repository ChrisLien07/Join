//
//  Pi_FullPostNavi.swift
//  join
//
//  Created by 連亮涵 on 2020/6/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class Pi_FullPostNavi: UINavigationController, UINavigationControllerDelegate {

    var pid : String = ""
    var uid : String = ""
    var scrolltoComt = false
    var cmtid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}
