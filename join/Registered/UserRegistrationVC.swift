//
//  UserRegistration_VC.swift
//  join
//
//  Created by ChrisLien on 2020/9/10.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserRegistrationVC: UIViewController,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var txt_gender: PickerTextField!
    @IBOutlet weak var txt_birthday: PickerTextField!
    
    let dp_Date = UIDatePicker()
    let genderPicker = UIPickerView()
    var seleGender = false
    var seleAge = false
    var foldername = ""
    let gender_array = ["男","女"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        txt_username.delegate = self
        txt_username.tag = 1
        txt_username.layer.borderWidth = 0.5
        txt_username.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
        txt_username.layer.cornerRadius = txt_username.frame.height/16
        txt_username.setPaddingPoints(txt_username.frame.height/2)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(txtEndEdit))
        self.view.addGestureRecognizer(tap)
        //
        btn_next.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        btn_next.isEnabled = false
        btn_next.layer.cornerRadius = btn_next.frame.height/2
        //
        genderPicker.delegate = self
        txt_gender.setPaddingPoints(10)
        txt_gender.tag = 3
        txt_gender.layer.cornerRadius = txt_gender.frame.height / 10
        txt_gender.inputView = genderPicker
        txt_gender.setToolbar(target: self, selector: #selector(tool_done))
        //
        txt_birthday.delegate = self
        txt_birthday.tag = 2
        txt_birthday.layer.borderWidth = 0.5
        txt_birthday.layer.borderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
        txt_birthday.inputView = dp_Date
        txt_birthday.setPaddingPoints(10)
        txt_birthday.layer.cornerRadius = txt_birthday.frame.height/16
        self.txt_birthday.setInputBirthdatePicker(target: self, selector: #selector(tapDone))
    }
    
    func callFolderNameService()
    {
        let request = createHttpRequest(Url: globalData.GetFolderNameUrl, HttpType: "POST", Data: "&phonenum=\(globalData.serverPhonenum)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        let folder = responseJSON["foldername"] as! String
                        self.foldername = folder
                        if self.foldername != "" {
                            self.nextPage()
                        }
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 1:
            var result = false
            if let text = textField.text, let range = Range(range, in: text)
            {
                let newText = text.replacingCharacters(in: range, with: string)
                if newText.count <= 20 {
                    result = true
                } else {
                    result = false
                }
             }
             return result
        case 2 :
            return false
        case 3:
            return false
        default:
            return false
        }
    }
    
    func checkSelected()
    {
        if seleAge == true , seleGender == true , txt_username.text?.count != 0
        {
            btn_next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_next.frame.height/2)
            btn_next.isEnabled = true
        }
    }
    
    func checkName(name:String) -> Bool
    {
        let pattern = "[^a-zA-Z一-龥]"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: name, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, name.count))
        if res.count > 0{return false}
        else{return true}
    }
    
    func nextPage()
    {
        if !self.checkName(name: self.txt_username.text!) {
            ShowErrMsg(code: 0, msg: "暱稱限用中英字母", vc: self)
            return
        } else {
            globalData.username = self.txt_username.text!
            Alert.verifyRegistrationAlert(vc: self, foldername: self.foldername)
        }
    }
    
    // MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return gender_array[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        txt_gender.text = gender_array[row]
    }
    // MARK: - @objc
    @objc func tapDone()
    {
        if let datePicker = self.txt_birthday.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            let today = NSDate()
             dateformatter.dateFormat = "yyyy-MM-dd"
            let dateOfBirth = datePicker.date
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let age = gregorian.components([.year], from: dateOfBirth, to: today as Date, options: [])
           
            self.txt_birthday.text = dateformatter.string(from: datePicker.date)
            if age.year! < 18 {
                seleAge = false
                checkSelected()
            } else {
                seleAge = true
                checkSelected()
            }
            globalData.birthday = dateformatter.string(from: datePicker.date)
        }
        self.txt_birthday.resignFirstResponder()
    }

    @objc func txtEndEdit() {
        self.view.endEditing(true)
        checkSelected()
    }
    
    @objc func tool_done() {
        genderPicker.delegate!.pickerView?(genderPicker, didSelectRow: genderPicker.selectedRow(inComponent: 0), inComponent: 0)
        if txt_gender.text == "男" {
            globalData.gender = "1"
            seleGender = true
        } else if txt_gender.text == "女" {
            globalData.gender = "2"
            seleGender = true
        }
        txt_gender.resignFirstResponder()
        checkSelected()
    }
    
    // MARK: - @IBAction
    
    @IBAction func next(_ sender: Any) {
        callFolderNameService()
    }
    
    @IBAction func back(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[2], animated: true)
        do
           {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "Token")
                UserDefaults.standard.synchronize()
           }
        catch
            {
                print(error)
            }
    }
}
