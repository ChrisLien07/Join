//
//  SettingVipPageVC.swift
//  join
//
//  Created by ChrisLien on 2020/9/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SettingVipPageVC: UIViewController {

    @IBOutlet weak var v_main: UIView!
    @IBOutlet weak var v_secondary: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(goVipPage))
        v_main.layer.cornerRadius = v_main.frame.height/16
        v_main.clipsToBounds = true
        v_main.addGestureRecognizer(tap)
        v_secondary.applyGradient(colors: [#colorLiteral(red: 1, green: 0.5137254902, blue: 0.09019607843, alpha: 1) , #colorLiteral(red: 1, green: 0.768627451, blue: 0, alpha: 1)], cornerRadius: v_secondary.frame.height/32)
        v_secondary.layer.cornerRadius = v_secondary.frame.height/32
        v_secondary.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    @IBAction func back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goVipPage()
    {
        if globalData.isVip == "N"
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
            vc.from = "設定"
            self.present(vc, animated: true)
        }
        else if globalData.isVip == "Y"
        {
            let alertController = UIAlertController(title: "您已是VIP", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title:"確認",style: .cancel))
            //顯示提示框
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
