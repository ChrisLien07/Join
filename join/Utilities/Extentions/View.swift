//
//  Views.swift
//  join
//
//  Created by ChrisLien on 2020/11/12.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

extension UIView {
    
    //找出目前顯示的viewcontroller
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    //設定constrain
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerAnchor(centerX: NSLayoutXAxisAnchor, centerY: NSLayoutYAxisAnchor, size: CGSize) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        centerXAnchor.constraint(equalTo: centerX).isActive = true
        
        centerYAnchor.constraint(equalTo: centerY).isActive = true
        
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    //設定漸層
    func applyGradient(colors: [CGColor], cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //設定特定圓角
    func maskedCornersGradient(colors: [CGColor], cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        if #available(iOS 11.0, *) {
            gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        }
        layer.addSublayer(gradientLayer)
    }
    
    //設定陰影
    func setupShadow(offsetWidth:CGFloat ,offsetHeight: CGFloat , opacity:Float,radius:CGFloat) {
        layer.shadowOffset = CGSize(width: offsetWidth,height: offsetHeight)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    //設定底線
    func setSingleSideBorder(frame: CGRect) {
        let border = CALayer()
        border.borderColor = UIColor.black.cgColor;
        border.borderWidth = 1;
        border.frame = frame
        layer.addSublayer(border)
    }
    
    //組建UserIcon
    func configureUserIcon(target: Any, cornerRadious: CGFloat, selector: Selector) {
        contentMode = .scaleAspectFill
        layer.masksToBounds = true
        isUserInteractionEnabled = true
        layer.cornerRadius = cornerRadious
        let iconTap = UITapGestureRecognizer.init(target: target, action: selector)
        addGestureRecognizer(iconTap)
    }
}
