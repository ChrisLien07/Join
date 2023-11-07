//
//  ProfileLabel.swift
//  join
//
//  Created by ChrisLien on 2020/11/19.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

//灰底個人資料
class ProfileLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(font:UIFont = .systemFont(ofSize: 16), textAlignment:NSTextAlignment = .natural, line: Int = 1, textColor: UIColor = .white) {
        self.init(frame: .zero)
        self.font = font
        self.textAlignment = textAlignment
        self.numberOfLines = line
        self.textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//追蹤人數 粉絲人數 人氣 聚會
class NumberLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStyle() {
        font = .systemFont(ofSize: 16)
        textAlignment = .center
        numberOfLines = 2
    }
}
