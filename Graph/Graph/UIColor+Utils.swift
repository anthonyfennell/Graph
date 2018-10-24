//
//  UIColor+Utils.swift
//  Graph
//
//  Created by Anthony Fennell on 10/23/18.
//  Copyright © 2018 Anthony Fennell. All rights reserved.
//

import UIKit

public extension UIColor {
    public convenience init(hex: Int) {
        let red = CGFloat(hex >> 16) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
