//
//  SettingsViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit

final class SettingsViewController: UIViewController, AppearanceDelegate {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        tableView.separatorStyle = .none
//        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    private(set) var dataSource: [[CellType]] = []

    private var lastSection: [CellType] {
        guard !UserDefaultsDataProvider.isPremium else { return [] }
        return [
            .text("Убрать рекламу", R.image.remove_ads_icon()),
            .text("Восстановить покупки", R.image.restoreIcon())
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadDataSource()
        setDelegates()
        configureLayout()
        configureColors()
        navigationItem.title = "Настройки"
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        }
        Appearance.add(self)
    }

    private func configureLayout() {
        view.addSubview(tableView)

        tableView.pin(to: view)
    }

    func configureColors() {
        tableView.backgroundColor = .clear
        tableView.subviews.forEach {
            ($0 as? SettingsCell)?.reloadColors()
        }
        view.backgroundColor = Colors.dividerColor
        navigationController?.navigationBar.barTintColor = Colors.dividerColor
        navigationController?.navigationBar.tintColor = Colors.dividerColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): Colors.textColor]
    }

    private func setDelegates() {
        AppStoreManagerObserver.shared.delegate = self
    }

    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
    }

    private func reloadDataSource() {
        dataSource = [
            [
                .switch("Звуки", UserDefaultsDataProvider.isSoundsActive, R.image.soundsIcon()),
                .switch("Музыка", UserDefaultsDataProvider.isMusicActive, R.image.musicIcon()),
                .switch("Вибрация", UserDefaultsDataProvider.isVibrationsActive, R.image.vibration_icon()),
                .switch("Тёмная тема", UserDefaultsDataProvider.isDarkModeActive, R.image.dark_mode_icon())
            ],
            [
                .text("Обучение", R.image.tutorialicon()),
                .text("Об игре", R.image.aboutGameIcon())
            ],
            lastSection
        ]
    }

    enum CellType {
        case `switch`(String, Bool, UIImage?)
        case text(String, UIImage?)
    }
}


extension SettingsViewController: SettingsCellDelegate {

    func switchDidPress(with text: String) {
        UserDefaultsDataProvider.toggleSwitch(with: text)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        let data = section[indexPath.row]

        switch data {
        case .switch: return
        case .text(let text, _):
            switch text {
            case "Обучение":
                HomeScreenViewController.setGameTypeTraining()
                restartGame()

            case "Убрать рекламу":
                AppStoreManagerObserver.shared.buy()

            case "Восстановить покупки":
                AppStoreManager.shared.restore()

            default:
                return
            }
        }
    }
}

extension SettingsViewController: AppStoreObserverDelegate {

    func productsPurchased(id: String) {
        reloadDataSource()
        tableView.reloadData()
    }
}
