//
//  CustomObject.swift
//  join
//
//  Created by ChrisLien on 2020/10/21.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class PickerTextField : UITextField
{
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
}


