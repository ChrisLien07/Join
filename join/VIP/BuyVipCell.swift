//
//  BuyVipCell.swift
//  join
//
//  Created by 連亮涵 on 2020/8/7.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class BuyVipCell: UICollectionViewCell {

    let v_color = UIView()
    let v_main = UIView()
    let lbl_inself = UILabel()
    let lbl_month = UILabel()
    let lbl_month_literal = UILabel()
    let lbl_price = UILabel()
    let v_line = UIView()
    
    let lbl_incolor: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = Colors.rgb149Gray
        return lbl
    }()
    
    let lbl_discount: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .center
        lbl.textColor = .red
        return lbl
    }()
    
    let lbl_perMonth: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .center
        lbl.textColor = Colors.rgb149Gray
        return lbl
    }()
    
    var productID = ""
    var item_id = ""
    var amount = ""
    var width:CGFloat = 0
    
    func init_buyVipBtn(item_memo: String,
                        amount: String,
                        item_id:String,
                        productID: String,
                        width:CGFloat)
    {
        self.productID = productID
        self.item_id = item_id
        self.amount = amount
        self.amount.removeFirst()
        self.amount = self.amount.replacingOccurrences(of: ",", with: "")
        let index = amount.index(amount.startIndex, offsetBy: 0)
        //
        self.layer.cornerRadius = self.frame.height/15
        //設定變色View
        v_color.frame = CGRect(x: 0, y: 0, width: width, height: 170)
        v_color.layer.cornerRadius = v_color.frame.height/15
        v_color.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1),#colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: v_color.frame.height/15)
        v_color.isHidden = true
        self.addSubview(v_color)
        //
        lbl_incolor.frame = CGRect(x: 0, y: 5, width: width, height: 20)
        //設定白色View
        v_main.frame = CGRect(x: 2.5, y: 30, width: width - 5, height: 137.5)
        v_main.backgroundColor = .white
        v_main.layer.cornerRadius = v_main.frame.height/15
        self.addSubview(v_main)
        //xx個月
        lbl_month.frame = CGRect(x: 30, y: 10, width: 30, height: 35)
        if item_id == "010" || item_id == "009" {
            lbl_month.frame.size.width = CGFloat(50)
        }
        lbl_month.font = .systemFont(ofSize: 45)
        //個月
        lbl_month_literal.frame = CGRect(x: lbl_month.frame.origin.x + lbl_month.frame.width , y: 23, width: 50, height: 30)
        lbl_month_literal.text = "個月"
        lbl_month_literal.font = .systemFont(ofSize: 12)
        //$xx/個月
        lbl_perMonth.frame = CGRect(x: 0, y: lbl_month.frame.height + lbl_month.frame.origin.y + 5, width: width, height: 15)
        //省下xx%
        lbl_discount.frame = CGRect(x: 0, y: lbl_perMonth.frame.origin.y + lbl_perMonth.frame.height + 2.5 , width: width, height: 25)
        //line
        v_line.frame = CGRect(x: 5, y: lbl_discount.frame.origin.y + lbl_discount.frame.height + 15 , width: width - 15, height: 1)
        v_line.backgroundColor = Colors.rgb188Gray
        //$xx
        lbl_price.frame = CGRect(x: 0, y: v_line.frame.origin.y + v_line.frame.height + 10 , width: width - 5, height: 15)
        let IntAmount = Float(self.amount)!
        lbl_price.text = "\(amount[index])" + "\(IntAmount)"
        lbl_price.textAlignment = .center
        lbl_price.font = .systemFont(ofSize: 20)
        [lbl_month,lbl_month_literal,lbl_perMonth,lbl_discount,v_line,lbl_price].forEach{ v_main.addSubview($0) }
        
        self.addSubview(lbl_incolor)
        //
        if item_id == "006" || item_id == "005" {
            lbl_month.text = "1"
            lbl_perMonth.text = "\(amount[index])" + "\(IntAmount)/個月"
        } else if item_id == "008" || item_id == "007" {
            let formatString: String = String(format: "%.2f", IntAmount/3)
            lbl_incolor.text = "最受歡迎"
            lbl_month.text = "3"
            lbl_discount.text = "省下33%"
            lbl_perMonth.text = "\(amount[index])" + "\(formatString)/個月"
        } else if item_id == "010" || item_id == "009" {
            let formatString: String = String(format: "%.2f", IntAmount/12)
            lbl_incolor.text = "最超值"
            lbl_month.text = "12"
            lbl_discount.text = "省下58%"
            lbl_perMonth.text = "\(amount[index])" + "\(formatString)/個月"
        }
    }
    
    func selectItem() {
        v_color.isHidden = false
        lbl_incolor.textColor = .white
        if let vc = self.findViewController() as? BuyVipVC {
            vc.seleProductID = self.productID
            vc.seleItem_id = self.item_id
        }
    }

    func deselectItem() {
        v_color.isHidden = true
        lbl_incolor.textColor = Colors.rgb149Gray
    }
}
