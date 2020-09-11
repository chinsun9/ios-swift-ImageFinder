//
//  UISwithCustom.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/11.
//  Copyright © 2020 sung hello. All rights reserved.
//



import UIKit
@IBDesignable

class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
