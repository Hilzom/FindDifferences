//
//  HomeScreenViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

final class HomeScreenViewController: UIViewController {

    // MARK: - Properties

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.blueColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playButtonDidPress), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight).isActive = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        return button
    }()

    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.appNameTitle
        label.font = UIFont.boldSystemFont(ofSize: Constants.labelFontSize)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateButton()
        configureLayout()
        configureColors()
        configureNavBar()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animateAlongsideTransition(in: view) { [weak self] _ in
            self?.updateButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateButton()
    }

    // MARK: - Functions

    func play() {
        switch GameTypeShared.type {
        case .real:
            playButtonDidPress()

        case .training:
            playTraining()
        }
    }

    // MARK: - Private functions

    private func configureNavBar() {
        let button = UIButton()
        button.setImage(R.image.settings_icon(), for: .normal)
        button.addTarget(self, action: #selector(settingsDidPress), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }

    private func configureLayout() {
        view.addSubview(playButton)
        view.addSubview(appNameLabel)

        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: GlobalConstants.horizontalSpacing),
            playButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -GlobalConstants.horizontalSpacing),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -GlobalConstants.horizontalSpacing),

            appNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.labelHorizontalSpacing),
            appNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.labelHorizontalSpacing),
            appNameLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func updateButton() {
        playButton.setTitle("\(Constants.buttonTitlePrefix) \(currentLvl)", for: .normal)
        playButton.layer.cornerRadius = UIScreen.main.bounds.width / Constants.buttonCornerRadiusDivider
    }

    private func configureColors() {
        view.backgroundColor = Colors.backgroundLight
    }

    private var currentLvl: Int {
        UserDefaultsDataProvider.currentLevel
    }
    private var currentDifferences: [Difference] {
        guard Self.testPoints.indices.contains(currentLvl - 1) else { return Self.testPoints[0] }
        return Self.testPoints[currentLvl - 1]
    }

    private var imageName: String {
        "level_\(currentLvl)"
    }
    @objc
    private func playButtonDidPress() {
        Self.setGameTypeReal()
        print("hehe playButtonDidPress")
        let gameVC = GameViewController(differencePoints: currentDifferences, topImage: "\(imageName)_top", bottomImage: "\(imageName)_bottom")
        navigationController?.pushViewController(gameVC, animated: true)
    }

    private func playTraining() {
        print("hehe playTraining")
        let gameVC = TrainingViewController(differencePoints: Self.testPoints[0], topImage: "level_1_top", bottomImage: "level_1_bottom")
        navigationController?.pushViewController(gameVC, animated: true)
    }

//    private static var testPoints: [Difference] {[
//        .init(percents: .init(x: 8, y: 84)),
//        .init(percents: .init(x: 9, y: -4)),
//        .init(percents: .init(x: 20, y: 57)),
//        .init(percents: .init(x: 26, y: 70)),
//        .init(percents: .init(x: 32.5, y: 75)), // ведро
//        .init(percents: .init(x: 37.5, y: 15)), // лампа
//        .init(percents: .init(x: 67, y: 8)), // куст вверху
//        .init(percents: .init(x: 60, y: 85)),
//        .init(percents: .init(x: 85, y: 75)),
//        .init(percents: .init(x: 95, y: 76.5))
//    ]}

    private static var testPoints: [[Difference]] {[
        [
            .init(percents: .init(x: 5, y: 30)), // доска
            .init(percents: .init(x: 37, y: 35)), // okno
            .init(percents: .init(x: 35, y: 85)),  // kover
            .init(percents: .init(x: 55, y: 45)), // podushka
            .init(percents: .init(x: 75, y: 85)), // nogi
            .init(percents: .init(x: 82, y: 58)), // polochka
            .init(percents: .init(x: 85, y: 25)) // cvetok
        ], // 1

        [
            .init(percents: .init(x: 20, y: 35)), // 123
            .init(percents: .init(x: 5, y: 63)), // забор
            .init(percents: .init(x: 21.5, y: 75)),  // красный мяч
            .init(percents: .init(x: 32, y: 8)), // стена
            .init(percents: .init(x: 39, y: 38)), // доска
            .init(percents: .init(x: 63.5, y: 63)), // дверца шкафа
            .init(percents: .init(x: 79, y: 33)), // куст
        ], // 2

        [
            .init(percents: .init(x: 24, y: 54)), // пустота на полке
            .init(percents: .init(x: 33, y: 19)), // пустота на стене
            .init(percents: .init(x: 45, y: 45)),  // жилет работяги
            .init(percents: .init(x: 50, y: 70)), // стул около работяги
            .init(percents: .init(x: 61.5, y: 42)), // доска
            .init(percents: .init(x: 67, y: 19)), // окно
            .init(percents: .init(x: 87, y: 60)), // коробка
        ], // 3

    ]}

    @objc
    private func settingsDidPress() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    // MARK: - Types

    private enum Constants {
        static let appNameTitle = "Differences"

        static let buttonTitlePrefix = "Уровень "
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadiusDivider: CGFloat = 20

        static let labelFontSize: CGFloat = 60
        static let labelHorizontalSpacing: CGFloat = 32
    }

    static func setGameTypeReal() {
        GameTypeShared.type = .real
    }

    static func setGameTypeTraining() {
        GameTypeShared.type = .training
    }

    static var isRealGame: Bool {
        return GameTypeShared.type == .real
    }

    struct GameTypeShared {
        static var type: GameType = .real
    }
}
