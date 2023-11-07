//
//  CustomKolodaView.swift
//  join
//
//  Created by 連亮涵 on 2020/8/13.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Koloda

let defaultTopOffset: CGFloat = 20
let defaultHorizontalOffset: CGFloat = 10
let defaultHeightRatio: CGFloat = 1.25
let backgroundCardHorizontalMarginMultiplier: CGFloat = 0.25
let backgroundCardScalePercent: CGFloat = 1.5

class CustomKolodaView: KolodaView {

    override func frameForCard(at index: Int) -> CGRect {
        if index == 0 {
            //let topOffset: CGFloat = defaultTopOffset
            //let xOffset: CGFloat = defaultHorizontalOffset
            //let width = (self.frame).width - 2 * defaultHorizontalOffset
            //let height = width * defaultHeightRatio
            //let yOffset: CGFloat = topOffset
            //let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            return frame
            
        }
        else if index == 1 {
            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width * backgroundCardScalePercent
            let height = width * defaultHeightRatio
            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
        }
        return CGRect.zero
    }

}

