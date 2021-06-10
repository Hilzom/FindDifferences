//
//  UIView+Helpers.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

extension UIView {

    func pin(to view: UIView, margin: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        ])
    }

    func pinToSafeArea(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func embedView(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        self.pin(to: view)
    }
}

extension UIButton {

    static func getSquaredButton(with size: CGFloat? = nil) -> UIButton {
        let button = UIButton()
        button.setImage(R.image.remove_ads_icon(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        if let size = size { button.heightAnchor.constraint(equalToConstant: size).isActive = true }
        return button
    }

    func withDisabledHighlight() -> Self {
        adjustsImageWhenHighlighted = false
        return self
    }
}
