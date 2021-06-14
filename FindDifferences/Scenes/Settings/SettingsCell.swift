//
//  SettingsCell.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {

    func switchDidPress(with text: String)
}

final class SettingsCell: UITableViewCell, CellIdentifiable {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var switchView: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = .systemBlue
        view.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        return view
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private weak var delegate: SettingsCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(style: .default, reuseIdentifier: Self.identifier)

        configureLayout()
    }

    func configure(with type: SettingsViewController.CellType, delegate: SettingsCellDelegate, isLast: Bool) {
        self.delegate = delegate
        dividerView.isHidden = isLast
        switch type {
        case let .switch(text, isActive, image):
            configure(text: text, isActive: isActive, image: image)

        case let .text(text, image):
            configure(text: text, isActive: nil, image: image)
        }
    }

    func configureSwitch(with value: Bool) {
        switchView.isOn = value
    }

    private func configure(text: String, isActive: Bool?, image: UIImage?) {
        titleLabel.text = text
        iconView.image = image

        if let isActive = isActive {
            switchView.isHidden = false
            switchView.isOn = isActive
            accessoryType = .none
        }
        else {
            switchView.isHidden = true
            accessoryType = .disclosureIndicator
        }
    }

    func reloadColors() {
        selectedBackgroundView?.backgroundColor = Colors.bgColor
        contentView.backgroundColor = Colors.bgColor
        accessoryView?.backgroundColor = Colors.bgColor
        backgroundColor = Colors.bgColor
        titleLabel.textColor = Colors.textColor
        dividerView.backgroundColor = Colors.dividerColor
    }

    private func configureLayout() {
        clipsToBounds = true
        let view = UIView()
        selectedBackgroundView = view
        reloadColors()

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchView)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: switchView.leadingAnchor),

            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            dividerView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    @objc private func switchValueDidChange() {
        delegate?.switchDidPress(with: titleLabel.text ?? "")
    }
}
