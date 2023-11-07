//
//  MyActivityIndicatorView.swift
//  join
//
//  Created by ChrisLien on 2020/12/8.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class MyActivityIndicatorView: UIView {
    
    let activityIndicater = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        isHidden = true
        backgroundColor = .black
        alpha = 0.5
        layer.cornerRadius = 20
        frame.size = CGSize(width: 100, height: 100)
        configureAV()
    }
    
    func configureAV() {
        addSubview(activityIndicater)
        activityIndicater.hidesWhenStopped = true
        activityIndicater.style = .whiteLarge
        activityIndicater.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func active() {
        isHidden = false
        superview?.isUserInteractionEnabled = false
        activityIndicater.startAnimating()
    }
    
    func inactive() {
        isHidden = true
        superview?.isUserInteractionEnabled = true
        activityIndicater.stopAnimating()
    }
}
