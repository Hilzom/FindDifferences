//
//  PauseCellProtocol.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import Foundation

protocol PauseCellProtocol: CellIdentifiable {

    func configure(with type: PopUpViewController.CellType)
}
