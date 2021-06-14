//
//  PauseButtonCell.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class PauseButtonCell: UITableViewCell, PauseCellProtocol {

    private let button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.backgroundColor = Constants.ButtonBackgroundColor
        button.isUserInteractionEnabled = false
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
        configureColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with type: PopUpViewController.CellType) {
        switch type {
        case .button(let text, let image):
            configureAsButton(with: text, image: image)

        default:
            AppDelegate.fatalErrorIfDebug()
            return

        }
    }

    func configureColors() {
        button.setTitleColor(.white, for: .normal)
        contentView.backgroundColor = Colors.bgColor
    }

    private func configureLayout() {
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func configureAsButton(with text: String, image: UIImage?) {
        button.setTitle(text, for: .normal)
        button.setImage(image, for: .normal)
//        button.imageView?.clipsToBounds = true
//        button.imageView?.contentMode = .scaleAspectFit
//        button.imageView?.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        button.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
//        button.contentHorizontalAlignment = .left
//        button.contentVerticalAlignment = .fill
    }

    private enum Constants {
        static let ButtonBackgroundColor: UIColor = .systemBlue
    }
}
