//
//  CellIdentifiable.swift
//  Themes
//
//  Created by Nikolay Chepizhenko on 01.05.2021.
//

import Foundation

protocol CellIdentifiable {

    // MARK: - Properties

    static var identifier: String { get }
}

extension CellIdentifiable {

    // MARK: - Properties

    static var identifier: String {
        return String(describing: self)
    }
}
