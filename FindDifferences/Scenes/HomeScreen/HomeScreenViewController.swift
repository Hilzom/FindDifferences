//
//  HomeScreenViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

final class HomeScreenViewController: UIViewController, AppearanceDelegate {

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
    private lazy var textView = UITextView()

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
        Appearance.add(self)
        addLevelControl()
    }
    let settingsButton = UIButton()

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
        settingsButton.setImage(R.image.settings_icon(), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsDidPress), for: .touchUpInside)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.widthAnchor.constraint(equalTo: settingsButton.heightAnchor).isActive = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
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

    func configureColors() {
        view.backgroundColor = Colors.bgColor
        appNameLabel.textColor = Colors.textColor
        settingsButton.tintColor = Colors.blueColor
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

    private static var testPoints: [[Difference]] {[
        [
            .init(percents: .init(x: 5, y: 30)), // ??????????
            .init(percents: .init(x: 37, y: 35)), // okno
            .init(percents: .init(x: 35, y: 85)),  // kover
            .init(percents: .init(x: 55, y: 45)), // podushka
            .init(percents: .init(x: 75, y: 85)), // nogi
            .init(percents: .init(x: 82, y: 58)), // polochka
            .init(percents: .init(x: 85, y: 25)) // cvetok
        ], // 1

        [
            .init(percents: .init(x: 20, y: 35)), // 123
            .init(percents: .init(x: 5, y: 63)), // ??????????
            .init(percents: .init(x: 21.5, y: 75)),  // ?????????????? ??????
            .init(percents: .init(x: 32, y: 8)), // ??????????
            .init(percents: .init(x: 39, y: 38)), // ??????????
            .init(percents: .init(x: 63.5, y: 63)), // ???????????? ??????????
            .init(percents: .init(x: 79, y: 33)), // ????????
        ], // 2

        [
            .init(percents: .init(x: 24, y: 54)), // ?????????????? ???? ??????????
            .init(percents: .init(x: 33, y: 19)), // ?????????????? ???? ??????????
            .init(percents: .init(x: 45, y: 45)),  // ?????????? ????????????????
            .init(percents: .init(x: 50, y: 70)), // ???????? ?????????? ????????????????
            .init(percents: .init(x: 61.5, y: 42)), // ??????????
            .init(percents: .init(x: 67, y: 19)), // ????????
            .init(percents: .init(x: 87, y: 60)), // ??????????????
        ], // 3

        [
            .init(percents: .init(x: 9, y: 44)), // ??????????????????
            .init(percents: .init(x: 33, y: -2)), // ??????????
            .init(percents: .init(x: 21, y: 63)),  // ??????????
            .init(percents: .init(x: 33, y: 61.5)), // ????????
            .init(percents: .init(x: 40, y: 29)), // ???????????? ??????????
            .init(percents: .init(x: 67.5, y: 5)), // ????????????????
            .init(percents: .init(x: 89.5, y: 35)), // ????????????
        ], // 4

        [
            .init(percents: .init(x: 4.5, y: 22)), // ??????????????
            .init(percents: .init(x: 15, y: 60)), // ????????
            .init(percents: .init(x: 43, y: 42)),  // ????????????
            .init(percents: .init(x: 39, y: 11)), // ??????????
            .init(percents: .init(x: 52.5, y: 13)), // ??????????????
            .init(percents: .init(x: 57, y: 73.5)), // ????????????
            .init(percents: .init(x: 89, y: 59)), // ??????????
        ], // 5

        [
            .init(percents: .init(x: 11.3, y: 64)), // ?????????? ??????????
            .init(percents: .init(x: 23, y: 27)), // ???????????? ??????????
            .init(percents: .init(x: 24, y: 56)),  // ????????
            .init(percents: .init(x: 51.5, y: 62)), // ?????????????? ??????????????????
            .init(percents: .init(x: 56.5, y: 30)), // ????????????????????
            .init(percents: .init(x: 72, y: 21.5)), // ????????
            .init(percents: .init(x: 65.5, y: 75)), // ??????????
        ], // 6

        [
            .init(percents: .init(x: 11.5, y: 73)), // ??????????????
            .init(percents: .init(x: 29, y: 7)),  // ?????????????????????? ????????????
            .init(percents: .init(x: 29, y: 35.5)), // ????????????
            .init(percents: .init(x: 39.5, y: 40)), // 5
            .init(percents: .init(x: 54.5, y: 26)), // ?????????????????????? ????????
            .init(percents: .init(x: 61, y: 76.5)), // ??????????????
            .init(percents: .init(x: 83, y: 20)), // ?????? ??????????
        ], // 7

        [
            .init(percents: .init(x: 13, y: 35)), // ??????????
            .init(percents: .init(x: 3.5, y: 70)), // ??????????????
            .init(percents: .init(x: 33, y: 37)), // ???????????? ??????????
            .init(percents: .init(x: 46, y: 49)),  // ?????????? ???? ??????????
            .init(percents: .init(x: 56, y: 48)), // ???????????? ???? ??????????
            .init(percents: .init(x: 62, y: 65.5)), // ??????????
            .init(percents: .init(x: 83, y: 38)), // ????????????
        ], // 8

        [
            .init(percents: .init(x: 9.5, y: 19)), // ?????????????? ???? ??????????
            .init(percents: .init(x: 16.5, y: 68.5)), // ????????
            .init(percents: .init(x: 34.3, y: 11)), // ????????????
            .init(percents: .init(x: 47, y: 40)),  // ??????????
            .init(percents: .init(x: 45.85, y: 83)), // ????????????
            .init(percents: .init(x: 54, y: 45)), // ??????????
            .init(percents: .init(x: 80, y: 46)), // ?????????? ?? ????????????????????????
        ], // 9

        [
            .init(percents: .init(x: 0.7, y: 29.6)), // ??????
            .init(percents: .init(x: 21, y: 16)), // ???????????? ????????
            .init(percents: .init(x: 24, y: 70)), // ??????????
            .init(percents: .init(x: 31.5, y: 22)), // ????????
            .init(percents: .init(x: 43, y: 52)),  // ??????????????
            .init(percents: .init(x: 76.5, y: 57)), // ???????? ??????????
            .init(percents: .init(x: 65.8, y: 23)), // ????????????
        ], // 10

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

        static let buttonTitlePrefix = "?????????????? "
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

extension HomeScreenViewController: UITextViewDelegate {

    private func addLevelControl() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.delegate = self
        textView.textColor = .systemRed
        textView.text = "\(UserDefaultsDataProvider.currentLevel)"
        textView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        textView.font = UIFont.boldSystemFont(ofSize: 30)
        textView.textAlignment = .center
        textView.backgroundColor = .lightGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func closeKeyboard() {
        textView.resignFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        guard !text.isEmpty else { return }
        guard let int = Int(text) else { return }
        UserDefaultsDataProvider.currentLevel = int
        updateButton()
    }
}
