//
//  LoginViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var btn_phone: UIButton!
    @IBOutlet weak var lbl_Login: UILabel!
    @IBOutlet weak var txt_Agree: UITextView!
    @IBOutlet weak var v_main: UIView!
    @IBOutlet weak var img_pic: UIImageView!
    
    let img_none = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupNavigationBar()
        setupBoard()
        configure_txt_agree()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.shadowImage = img_none
    }
    
    func setupBoard() {
        v_main.layer.cornerRadius = v_main.frame.height/16
        img_pic.contentMode = .scaleAspectFill
        btn_phone.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_phone.frame.height/2)
        btn_phone.layer.cornerRadius = btn_phone.frame.height/2
    }
    
    func setupPolicyAttributed() {
        //使用條款、隱私權政策
        let textRange1 = NSMakeRange(17, 4)
        let textRange2 = NSMakeRange(22, 5)
        let attributedString = NSMutableAttributedString(string: "註冊/登入即代表同意 揪in 的\n服務條款和隱私權政策")
        let serviceUrl_privacyUrl = URL(string: globalData.serviceUrl_privacyUrl)!
        // Set the substring to be the linkNSAttributedString.Key.underlineStyle,
        attributedString.setAttributes([.link: serviceUrl_privacyUrl, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: textRange2)
        attributedString.setAttributes([.link: serviceUrl_privacyUrl, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: textRange1)
        txt_Agree.attributedText = attributedString
    }
    
    func configure_txt_agree() {
        setupPolicyAttributed()
        txt_Agree.isUserInteractionEnabled = true
        txt_Agree.isEditable = false
        txt_Agree.font = .systemFont(ofSize: 16)
        txt_Agree.textAlignment = .center
        txt_Agree.linkTextAttributes = [ .foregroundColor: UIColor.purple ]
    }
    
    @IBAction func PhoneTap() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneAuthVC") as! UserPhoneViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
