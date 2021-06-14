//
//  ImageCell.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 29.05.2021.
//

import UIKit

final class ImageCell: UITableViewCell, PauseCellProtocol {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
        configureColors()
    }

    required init?(coder: NSCoder) {
        super.init(style: .default, reuseIdentifier: Self.identifier)

        configureLayout()
    }

    func configureColors() {
        contentView.backgroundColor = Colors.bgColor
    }

    func configure(with type: PopUpViewController.CellType) {
        switch type {
        case .image(let image):
            iconView.image = image

        default:
            AppDelegate.fatalErrorIfDebug()
            return
        }
    }

    private func configureLayout() {
        contentView.addSubview(iconView)

        iconView.pin(to: contentView)
    }
}
