//
//  UIColor+Helpers.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit.UIColor

extension UIColor {
    public convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    public var rgbString: String {
        var red: CGFloat = 0,
            green: CGFloat = 0,
            blue: CGFloat = 0,
            alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%X%X%X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
