//
//  UpdateListsVC.swift
//  join
//
//  Created by ChrisLien on 2020/10/15.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UpdateListsVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txt_picker: PickerTextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_down: UIImageView!
    
    let picker = UIPickerView()
    
    let job_txtArray : [String] = ["不透露","學生","新軍人/警察","政府機關","製造業/工業","交通運輸業","醫療相關","網路/IT/電信","娛樂/影視","服務業","媒體/公關","教育/科研","運動選手","自由業","其他行業"]
    let job_idArray : [String] = ["001","002","003","004","005","006","007","008","009","010","011","012","013","014","015"]
    var job_combineArray = [Combine]()
    
    let relationship_txtArray : [String] = ["網上朋友","短暫浪漫","戀愛伴侶","吃喝玩樂","以結婚為前提","其他"]
    let relationship_id_Array : [String] = ["001","002","003","004","005","006"]
    var relationship_combineArray:[Combine] = [Combine]()
    
    var selectedArray = [Combine]()
    var selectedItem: Combine = Combine()
    var from = ""
    var pickerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let screenWidth = UIScreen.main.bounds.width
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let btn_done = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(tool_done))
        toolBar.setItems([flexible, btn_done], animated: false)
        toolBar.isUserInteractionEnabled = true
        //
        picker.delegate = self
        picker.dataSource = self
        txt_picker.textColor = .black
        txt_picker.text = "請選擇"
        txt_picker.textColor = Colors.rgb149Gray
        txt_picker.layer.cornerRadius = txt_picker.frame.height / 10
        txt_picker.inputView = picker
        txt_picker.inputAccessoryView = toolBar
        //
        img_down.frame = CGRect(x: txt_picker.frame.origin.x + txt_picker.frame.width - 30, y: txt_picker.frame.origin.y +  14.5, width: 15, height: 15)
        //
        job_combineArray = combineArray(idArr: job_idArray, txtArr: job_txtArray)
        relationship_combineArray = combineArray(idArr: relationship_id_Array, txtArr: relationship_txtArray)
        switch from
        {
        case "job":
            self.title = "我的職業"
            lbl_title.text = "選擇職業"
            pickerCount = job_combineArray.count
            selectedArray = job_combineArray
        case "relationship":
            self.title = "尋找關係"
            lbl_title.text = "尋找關係"
            pickerCount = relationship_combineArray.count
            selectedArray = relationship_combineArray
        default:
            break
        }        
    }
    
    @objc func tool_done() {
        view.endEditing(true)
    }

    @IBAction func back(_ sender: Any) {
        if selectedItem.id != "" {
            switch from
            {
                case "job":
                    globalData.tmpJob = selectedItem
                case "relationship":
                    globalData.tmpRelationship = selectedItem
                default:
                    break
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension UpdateListsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCount
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return selectedArray[row].txt
        
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        txt_picker.text = selectedArray[row].txt
        selectedItem = selectedArray[row]
    }
}
