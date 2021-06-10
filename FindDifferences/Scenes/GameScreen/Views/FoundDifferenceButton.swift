//
//  FoundDifferenceButton.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class FoundDifferenceButton: UIButton {


    var isActive = false

    func setActive() {
        isActive = true
        setImage(R.image.difference_found(), for: .normal)
        setTitle("", for: .normal)
        backgroundColor = .clear
    }

    func setInactive() {
        isActive = false
        backgroundColor = UIColor(white: 0.85, alpha: 1)
        setTitle("?", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitleColor(.darkGray, for: .normal)
    }

    override var frame: CGRect {
        didSet {
            layer.cornerRadius = frame.width / 2
        }
    }

    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = frame.width / 2
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        clipsToBounds = true
        setInactive()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension Array where Element == FoundDifferenceButton {
    func reloadState(with differences: [Difference]) {
        let foundCount = differences.foundCount
        for (index, element) in self.enumerated() {
            guard index < foundCount else { return }
            element.setActive()
        }
    }
}
