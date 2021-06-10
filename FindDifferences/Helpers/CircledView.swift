//
//  CircledView.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 06.06.2021.
//

import UIKit

final class CircledView: UIView {

    // MARK: - Properties

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

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        configureView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    // MARK: - Private functions

    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        clipsToBounds = true
    }

    private func configureCornerRadius() {
        layer.cornerRadius = frame.width / 2
    }
}

