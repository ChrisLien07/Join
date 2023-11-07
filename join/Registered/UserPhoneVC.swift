//
//  CheckPhoneViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import FirebaseAuth


class UserPhoneViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var txt_Area: PickerTextField!
    @IBOutlet weak var txt_PhoneNum: UITextField!
    @IBOutlet weak var btn_Send: UIButton!
    @IBOutlet weak var lbl_Warning: UILabel!
    
    let pv_area = UIPickerView()
    var verificationID : String = ""
    let areaArray = ["+886 台灣","+86 中國","+852 香港","+853 澳門","+65 新加坡","+60 馬來西亞","+1 美國","+1 加拿大","+61 澳洲","+64 紐西蘭"]
    var phoneNumber : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        pv_area.delegate = self
        pv_area.dataSource = self
        //區域碼
        txt_Area.delegate = self
        txt_Area.frame = CGRect(x: 21, y: 230, width: 85, height: 30)
        txt_Area.inputView = pv_area
        txt_Area.text = areaArray[0].components(separatedBy: " ")[0]
        txt_Area.setBottomBorder()
        txt_Area.tag = 1
        //手機號
        txt_PhoneNum.delegate = self
        txt_PhoneNum.frame = CGRect(x: txt_Area.frame.origin.x + txt_Area.frame.width, y: 230, width: self.view.frame.width - 85 - 46, height: 30)
        txt_PhoneNum.tag = 2
        txt_PhoneNum.placeholder = "0912 345 678"
        txt_PhoneNum.setBottomBorder()
        //送出
        btn_Send.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_Send.frame.height/2)
        btn_Send.layer.cornerRadius = btn_Send.frame.height/2
        //警告
        lbl_Warning.isHidden = true
        //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        self.view.addGestureRecognizer(tap)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return areaArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return areaArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       txt_Area.text = areaArray[row].components(separatedBy: " ")[0]
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{return true}
    
        if textField.tag == 1 {
            return false
        } else if textField.tag == 2 {
            let textLength = text.count + string.count - range.length
            
            switch txt_Area.text {
            case "+86" :
                return textLength <= 11
            case "+886":
                return textLength <= 10
            case "+852":
                return textLength <= 8
            case "+853":
                return textLength <= 8
            case "+65":
                return textLength <= 8
            case "+60":
                return textLength <= 9
            case "+1":
                return textLength <= 10
            case "+61":
                return textLength <= 9
            case "+64":
                return textLength <= 10
            default:
               return textLength <= 11
            }
            
        } else {
            return true
        }
    }
    
    func checkPhone(area: String, num: String) -> Bool
    {
        switch area {
        case "+86" :
            return (num.count == 11 && "1".contains(num.first!))
        case "+886":
            return (num.count == 9 && "9".contains(num.first!))
        case "+852":
            return num.count == 8
        case "+853":
            return num.count == 8
        case "+65":
            return num.count == 9
        case "+60":
            return num.count == 9
        case "+1":
            return num.count == 10
        case "+61":
            return num.count == 9
        case "+64":
            return num.count == 10
        default:
           return false
        }
    }
    
    @IBAction func send(_ sender: Any) {
        if txt_Area.text == "+886" && txt_PhoneNum.text!.starts(with: "0") {
            txt_PhoneNum.text!.removeFirst()
        }
        if checkPhone(area: txt_Area.text!, num: txt_PhoneNum.text!) {
            phoneNumber = txt_Area.text! + txt_PhoneNum.text!
            lbl_Warning.isHidden = true
            globalData.phonenum = phoneNumber
            
            let newPhoneNu = globalData.phonenum.replacingOccurrences(of: "+", with: "%2B")
            globalData.serverPhonenum = newPhoneNu
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CaptchaVC") as! CaptchaViewController
            self.navigationController?.pushViewController(vc,animated: true)
        } else {
            lbl_Warning.isHidden = false
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated:  true)
    }
}
