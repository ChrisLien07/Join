//
//  UnlockVC.swift
//  join
//
//  Created by ChrisLien on 2020/8/24.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UnlockVC: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_detail: UILabel!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var lbl_unlock: UILabel!
    
    var isSuperLike = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSuperLike {
            lbl_unlock.text = "超級喜歡"
            img.image = UIImage(named: "superlike.jpg")
            lbl_detail.text = "透過「超級喜歡」脫穎而出\n 讓對方知道你的心意!!"
        } else {
            img.image = UIImage(named: "back.jpg")
        }
        btn_back.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_back.frame.height/2)
        btn_back.layer.cornerRadius = btn_back.frame.height/2
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
}
