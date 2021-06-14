//
//  DifferenceView.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class DifferenceView: UIView {

    let model: Difference // Вова, это хуевая идея. Не делай так

    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            configureCornerRadius()
        }
    }

    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }
            configureCornerRadius()
        }
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerRadius()
    }

    func setSelected() {
        layer.borderColor = UIColor.systemGreen.cgColor
    }

    required init(with model: Difference) {
        self.model = model

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 3
        layer.borderColor = UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureCornerRadius() {
        layer.cornerRadius = frame.width / 2
    }
}
