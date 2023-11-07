//
//  ChatroomDateCell.swift
//  join
//
//  Created by ChrisLien on 2020/9/28.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ChatroomDateCell: UITableViewCell {

    @IBOutlet weak var lbl_date: UILabel!
    
    func init_date(msg: String)
    {
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        lbl_date.text = msg
        lbl_date.textColor = Colors.rgb149Gray
        lbl_date.font = .systemFont(ofSize: 13)
    }
}
