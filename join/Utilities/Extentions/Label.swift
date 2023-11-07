//
//  Label.swift
//  join
//
//  Created by ChrisLien on 2020/11/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

extension UILabel
{
    //MARK: -圖文Label
    func addIconToLabel(img: UIImage, labelText: String, bounds_x: Double, bounds_y: Double, boundsWidth: Double, boundsHeight: Double) {
        let attachment = NSTextAttachment()
        attachment.image = img
        attachment.bounds = CGRect(x: bounds_x, y: bounds_y, width: boundsWidth, height: boundsHeight)
        let attachmentStr = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: "")
        string.append(attachmentStr)
        let string2 = NSMutableAttributedString(string: labelText)
        string.append(string2)
        self.attributedText = string
    }
    
    func addStartoLabel(img: UIImage, labelText: String) {
        addIconToLabel(img: img, labelText: labelText, bounds_x: -2, bounds_y: -0.5, boundsWidth: 12, boundsHeight: 12)
    }
    
    //MARK: -雙色Label
    func makeLable(string1: String, string2: String) {
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(red: 113/255, green: 30/255, blue: 213/255, alpha: 1)]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)]
        let attributedString1 = NSMutableAttributedString(string: string1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string: string2, attributes:attrs2)
        attributedString1.append(attributedString2)
        self.attributedText = attributedString1
    }
}
