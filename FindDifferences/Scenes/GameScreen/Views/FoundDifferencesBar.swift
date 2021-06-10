//
//  FoundDifferencesBar.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class FoundDifferencesBar: UIStackView {

    private let differences: [Difference]
    private var differencesButtons: [FoundDifferenceButton]

    var currentView: UIView? {
        differencesButtons.first(where: { !$0.isActive })
    }

    required init(differences: [Difference]) {
        self.differences = differences
        differencesButtons = differences.compactMap { _ in FoundDifferenceButton() }

        super.init(frame: .zero)

        configureSubviews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        differencesButtons.reloadState(with: differences)
    }

    private func configureSubviews() {
        differencesButtons.forEach { addArrangedSubview($0) }
        axis = .horizontal
        distribution = .fillEqually
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
}
