//
//  GlobalConstants.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit.UIColor

enum GlobalConstants {

    static let is13iOSorHigher: Bool = {
        guard #available(iOS 13.0, *) else { return false }
        return true
    }()
    static let horizontalSpacing: CGFloat = 16
}

enum Colors {
    static let backgroundLight = UIColor.white
    static let blueColor = UIColor.systemBlue
    static let blurBgColor: UIColor = .black.withAlphaComponent(0.55)
}
