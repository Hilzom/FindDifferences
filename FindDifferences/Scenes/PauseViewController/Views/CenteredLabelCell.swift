//
//  CenteredLabelCell.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class CenteredLabelCell: UITableViewCell, PauseCellProtocol {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with type: PopUpViewController.CellType) {
        switch type {
        case .exit:
            configureAsExit()

        case .title(let text), .text(let text):
            configureAsTitle(with: text)

        default:
            AppDelegate.fatalErrorIfDebug()
            return

        }
    }

    private func configureLayout() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func configureAsExit() {
        titleLabel.text = "В меню"
        titleLabel.textColor = Constants.exitColor
    }

    private func configureAsTitle(with text: String) {
        titleLabel.text = text
        titleLabel.textColor = Constants.titleColorColor
    }

    private enum Constants {
        static let titleColorColor: UIColor = .black
        static let exitColor: UIColor = .systemBlue
    }
}
