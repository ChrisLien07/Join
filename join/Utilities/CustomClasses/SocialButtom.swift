//
//  SocialButtom.swift
//  join
//
//  Created by ChrisLien on 2020/11/12.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SocialButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        setupShadow(offsetWidth: 0, offsetHeight: 5, opacity: 0.1, radius: 5)
        backgroundColor = .white
        layer.cornerRadius = frame.height/2
    }
}
