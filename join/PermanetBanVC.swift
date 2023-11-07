//
//  PermanentBanVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/20.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class PermanentBanVC: UIViewController {

    @IBOutlet weak var v_main: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_reason: UILabel!
    @IBOutlet weak var btn_close: UIButton!
    
    var reason = ""
    var annTitle = ""
    var annContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        v_main.layer.cornerRadius = 15
        setupLabel()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        v_main.center = self.view.center
    }
    
    func setupLabel() {
        if annContent != "" {
            lbl_title.text = annTitle
            lbl_reason.text = annContent
        } else {
            lbl_reason.text = reason
        }
    }
    
    func setupButton() {
        if annContent != "" {
            btn_close.isHidden = false
            btn_close.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_close.frame.height/2)
            btn_close.layer.cornerRadius = 20
        }
    }
    
    @IBAction func tapClose(_ sender: Any) {
        UserDefaults.standard.set(getTPETime(format: "yyyyMMdd"), forKey: "TodayInfo")
        dismiss(animated: true, completion: nil)
    }
    
}
    
