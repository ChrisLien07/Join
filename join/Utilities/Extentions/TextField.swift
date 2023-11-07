//
//  TextField.swift
//  join
//
//  Created by ChrisLien on 2020/11/12.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

extension UITextField {

    func setInputBirthdatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        datePicker.locale = Locale(identifier: "Chinese")
        //
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        components.year = -65
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        self.inputView = datePicker
        setToolbar(target: target, selector: selector)
    }
    
    func setInputPostJoDatePicker(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker()
        datePicker.minuteInterval = 5
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 216)//1
        datePicker.datePickerMode = .dateAndTime//2
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        inputView = datePicker
        textAlignment = .right
        setPaddingPoints(10)
        setToolbar(target: target, selector: selector)
    }
    
    func setupTextFieldPicker(pv:UIPickerView, target: Any, toolbarAction: Selector) {
        inputView = pv
        textAlignment = .right
        setPaddingPoints(10)
        setToolbar(target: target, selector: toolbarAction)
    }
    
    func setToolbar(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) 
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "完成", style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    func setPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
        rightView = paddingView
        rightViewMode = .always
    }
    
    func setBottomBorder() {
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        setupShadow(offsetWidth: 0, offsetHeight: 1, opacity: 1, radius: 0)
    }
}
