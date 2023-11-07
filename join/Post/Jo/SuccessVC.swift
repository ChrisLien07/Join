//
//  SuccessPopVC.swift
//  join
//
//  Created by 連亮涵 on 2020/7/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SuccessVC: UIViewController {

    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_title.font = .boldSystemFont(ofSize: 25)
        btn_Next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_Next.frame.height/2)
        btn_Next.layer.cornerRadius = btn_Next.frame.height/2
    }
    
    @IBAction func next(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
