//
//  EmailPopVC.swift
//  join
//
//  Created by 連亮涵 on 2020/7/22.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ContactVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
