//
//  UserProfileNavi.swift
//  join
//
//  Created by ChrisLien on 2020/8/28.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UserProfileNavi: UINavigationController, UINavigationControllerDelegate {
    
    var isMatch = false
    var uid = ""
    var isRen = false
    var isPresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}
