//
//  ViewController.swift
//  join
//
//  Created by ChrisLien on 2020/11/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

extension UIViewController {
    func findViewController() -> UIViewController? {
        //找出目前顯示的viewcontroller
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func findTabBarController() -> UITabBarController? {
        //找出目前顯示的viewcontroller
        if self.tabBarController != nil {
            return self.tabBarController
        } else if let nextResponder = self.next as? UIViewController {
            return nextResponder.findTabBarController()
        } else {
            return nil
        }
    }
    
    func hideMainBar() {
        (self.findTabBarController() as! MainTabBar).tabBar.isHidden = true
    }
    
    func showMainBar() {
        (self.findTabBarController() as! MainTabBar).tabBar.isHidden = false
    }
    
    @objc func endEdit() {
        self.view.endEditing(true)
    }
}
