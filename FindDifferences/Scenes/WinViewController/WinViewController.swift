//
//  WinViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 29.05.2021.
//

import UIKit

final class WinViewController: UIViewController {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let homeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Главная", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toHomeScreen), for: .touchUpInside)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Продолжить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        return button
    }()

    private var isRealGame: Bool {
        HomeScreenViewController.isRealGame
    }

    private var currentLevel: Int {
        isRealGame ? UserDefaultsDataProvider.currentLevel : 1
    }

    private var labelText: String {
        isRealGame ? "Уровень \(currentLevel) завершен!" : "Обучение успешно завершено!"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        view.backgroundColor = .systemBlue

        guard isRealGame else { return }
        UserDefaultsDataProvider.currentLevel += 1
    }

    private func configureLayout() {
        view.addSubview(label)
        view.addSubview(homeButton)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            homeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            homeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nextButton.bottomAnchor.constraint(equalTo: homeButton.topAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
