//
//  NewLocationVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class NewLocationVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var txt_country: PickerTextField!
    @IBOutlet weak var txt_city: PickerTextField!
    @IBOutlet weak var img_down1: UIImageView!
    @IBOutlet weak var img_down2: UIImageView!
    
    let countryrPicker = UIPickerView()
    let cityPicker = UIPickerView()
    
    let countryPickerArray = ["台灣","國外"]
    let city_txt_Array : [String] = ["基隆市","台北市","新北市","桃園市","新竹市","新竹縣","苗栗縣","台中市","彰化縣","南投縣","雲林縣","嘉義市","嘉義縣","台南市","高雄市","屏東縣","台東縣","花蓮縣","宜蘭縣","澎湖縣","金門縣","連江縣"]
    let city_id_Array : [String] = ["001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022"]
    var city_Combine_Array = [Combine]()
    let abroad_txt_Array : [String] = ["大陸","港澳","星馬","美加","紐奧","其他"]
    let abroad_id_Array : [String] = ["024","025","026","027","028","029"]
    var abroad_Combine_Array = [Combine]()
    
    var selectedArray = [Combine]()
    var selectedItem: Combine = Combine()
        
    var from = ""
    var pickerCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if from == "update" {
            title = "目前居住地"
            navigationItem.rightBarButtonItem = .none
            btn_next.isHidden = true
        }
        city_Combine_Array = combineArray(idArr: city_id_Array, txtArr: city_txt_Array)
        abroad_Combine_Array = combineArray(idArr: abroad_id_Array, txtArr: abroad_txt_Array)
        //
        countryrPicker.delegate = self
        countryrPicker.dataSource = self
        countryrPicker.tag = 0
        txt_country.textColor = Colors.rgb149Gray
        txt_country.text = "請選擇"
        txt_country.layer.cornerRadius = txt_country.frame.height / 10
        txt_country.inputView = countryrPicker
        txt_country.setToolbar(target: self, selector: #selector(country_done))
        //
        cityPicker.delegate = self
        cityPicker.dataSource = self
        cityPicker.tag = 1
        txt_city.textColor = Colors.rgb149Gray
        txt_city.text = "請選擇"
        txt_city.layer.cornerRadius = txt_city.frame.height / 10
        txt_city.inputView = cityPicker
        txt_city.setToolbar(target: self, selector: #selector(city_done))
        //
        btn_next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_next.frame.height/2)
        btn_next.layer.cornerRadius = btn_next.frame.height/2
        //
        img_down1.frame = CGRect(x: txt_country.frame.origin.x + txt_country.frame.width - 30, y: txt_country.frame.origin.y +  14.5, width: 15, height: 15)
        img_down2.frame = CGRect(x: txt_city.frame.origin.x + txt_city.frame.width - 30, y: txt_city.frame.origin.y +  14.5, width: 15, height: 15)
        //
        pickerCount = city_Combine_Array.count
        selectedArray = city_Combine_Array
    }
    
    @objc func city_done() {
        cityPicker.delegate!.pickerView?(cityPicker, didSelectRow: cityPicker.selectedRow(inComponent: 0), inComponent: 0)
        view.endEditing(true)
    }
    
    @objc func country_done() {
        countryrPicker.delegate!.pickerView?(countryrPicker, didSelectRow: countryrPicker.selectedRow(inComponent: 0), inComponent: 0)
        self.view.endEditing(true)
        print(selectedItem.txt)
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if selectedItem.id != "" {
            globalData.location  = selectedItem.id
            let VC = storyboard!.instantiateViewController(withIdentifier: "InterestVC") as! UserInterestsViewController
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            shortInfoMsg(msg: "請選擇一項", vc: self, sec: 2)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if from == "update" {
            if selectedItem.id != "" {
                 globalData.tmpLocation = selectedItem
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewLocationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag
        {
        case 0:
            return 2
        case 1:
            return pickerCount
        default:
            return 0
       }
    }

    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        switch pickerView.tag
        {
        case 0:
            return countryPickerArray[row]
        case 1:
            return selectedArray[row].txt
        default:
             return ""
       }
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag
        {
        case 0:
            txt_country.text = countryPickerArray[row]
            if txt_country.text == "台灣" {
                selectedArray = city_Combine_Array
                pickerCount = city_Combine_Array.count
            } else if txt_country.text == "國外" {
                selectedArray = abroad_Combine_Array
                pickerCount = abroad_Combine_Array.count
            }
        case 1:
            txt_city.text = selectedArray[row].txt
            selectedItem = selectedArray[row]
        default:
             break
       }
    }
}
