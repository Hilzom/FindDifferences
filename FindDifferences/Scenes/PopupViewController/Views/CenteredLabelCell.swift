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
        label.numberOfLines = .zero
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
        configureColors()
    }
    private var isExit: Bool = false

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

    func configureColors() {
        titleLabel.textColor = isExit ? Constants.exitColor : Colors.textColor
        contentView.backgroundColor = Colors.bgColor
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
        isExit = true
        titleLabel.text = "В меню"
        configureColors()
    }

    private func configureAsTitle(with text: String) {
        isExit = false
        titleLabel.text = text
        configureColors()
    }

    private enum Constants {
        static let titleColorColor: UIColor = .black
        static let exitColor: UIColor = .systemBlue
    }
}
