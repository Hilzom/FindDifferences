//
//  PauseViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 25.05.2021.
//

import UIKit

final class PopUpViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        tableView.register(PauseSwitchCell.self, forCellReuseIdentifier: PauseSwitchCell.identifier)
        tableView.register(CenteredLabelCell.self, forCellReuseIdentifier: CenteredLabelCell.identifier)
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.identifier)
        tableView.register(PauseButtonCell.self, forCellReuseIdentifier: PauseButtonCell.identifier)

        tableView.layer.cornerRadius = 15
        tableView.clipsToBounds = true
        return tableView
    }()
    let dataSource: [CellType]
    let type: PopUpType

    var onCloseCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBlur()
        configureColors()
        configureLayout()
    }

    required init(with type: PopUpType) {
        switch type {
        case .pause:
            dataSource = CellType.pauseModels

        case .gameOver:
            dataSource = CellType.gameOverModels

        case .noVideoAd:
            dataSource = CellType.noVideoAdModel
        }
        self.type = type
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureColors() {
        view.backgroundColor = .clear
        tableView.backgroundColor = .white
    }

    deinit {
        print("hehe pause deinit")
    }

    private func configureLayout() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureBlur() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        blurEffectView.pin(to: view)
    }

    enum PopUpType {
        case pause
        case gameOver
        case noVideoAd
    }

    enum CellType {
        case title(String)
        case `switch`(String, Bool, UIImage?)
        case button(String, UIImage?)
        case exit
        case text(String)
        case image(UIImage?)

        static var pauseModels: [CellType] {
            [
            .title("Пауза"),
            .switch("Звуки", UserDefaultsDataProvider.isSoundsActive, R.image.soundsIcon()),
            .switch("Музыка", UserDefaultsDataProvider.isMusicActive, R.image.musicIcon()),
            .switch("Вибрация", UserDefaultsDataProvider.isVibrationsActive, nil),
            .button("Продолжить", nil),
            .exit
        ]
        }

        static let gameOverModels: [CellType] = [
            .title("Время вышло!"),
            .image(R.image.clockIcon()),
            .button("Получите 60 секунд", nil),
            .text("Перезапустить")
        ]

        static let noVideoAdModel: [CellType] = [
            .title("Видео недоступно в данный момент.\nПовторите попытку позже."),
            .button("OK", nil)
        ]
    }

    var tableViewHeight: CGFloat {
        switch type {
        case .gameOver, .pause:
            return headerTitle + Constants.switchCellHeight * 3 + Constants.buttonCellHeight + Constants.exitCellHeight + 16

        case .noVideoAd:
            return headerTitle + Constants.buttonCellHeight + 16
        }
    }

    var headerTitle: CGFloat {
        switch type {
        case .noVideoAd:
            return Constants.bigHeaderTitleHeight

        default:
            return Constants.headerTitleCellHeight
        }
    }

    private enum Constants {
        static let bigHeaderTitleHeight: CGFloat = 100
        static let headerTitleCellHeight: CGFloat = 60
        static let textCellHeight: CGFloat = 40
        static let switchCellHeight: CGFloat = 50
        static let buttonCellHeight: CGFloat = 60
        static let exitCellHeight: CGFloat = 40
        static let imageCellHeight: CGFloat = 150
    }
}

extension PopUpViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.row]
        switch type {
        case .switch:
            return switchCell(type: type, indexPath: indexPath, tableView: tableView)

        case .exit, .title, .text:
            return cell(with: type, indexPath: indexPath, tableView: tableView, type: CenteredLabelCell.self)

        case .button:
            return cell(with: type, indexPath: indexPath, tableView: tableView, type: PauseButtonCell.self)

        case .image:
            return cell(with: type, indexPath: indexPath, tableView: tableView, type: ImageCell.self)

        }
    }

    private func cell<Type: UITableViewCell & PauseCellProtocol>(with cellType: CellType,
                                               indexPath: IndexPath,
                                               tableView: UITableView,
                                               type: Type.Type) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Type.identifier, for: indexPath) as! Type
        cell.configure(with: cellType)
        cell.selectedBackgroundView = UIView()
        return cell
    }

    private func switchCell(type: CellType,
                            indexPath: IndexPath,
                            tableView: UITableView) -> UITableViewCell {
        let cell = cell(with: type, indexPath: indexPath, tableView: tableView, type: PauseSwitchCell.self) as! PauseSwitchCell
        cell.delegate = self
        cell.configure(with: type)
        return cell
    }
}

extension PopUpViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.row] {
        case .button:
            return Constants.buttonCellHeight

        case .exit:
            return Constants.exitCellHeight

        case .switch:
            return Constants.switchCellHeight

        case .title:
            return headerTitle

        case .text:
            return Constants.textCellHeight

        case .image:
            return Constants.imageCellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = dataSource[indexPath.row]
        switch type {
        case .gameOver:
            switch cellType {
            case .button:
                print("ad")

            case .text:
                restartGame()

            default: return
            }

        case .pause, .noVideoAd:
            switch cellType {
            case .button:
                dismiss(animated: true) { [weak self] in
                    self?.onCloseCompletion?()
                }

            case .exit:
                toHomeScreen()

            default: return
            }
        }
    }
}

extension PopUpViewController: SettingsCellDelegate {

    func switchDidPress(with text: String) {
        UserDefaultsDataProvider.toggleSwitch(with: text)
    }
}












extension UIViewController {

    @objc
    func toHomeScreen() {

        (presentingViewController as? UINavigationController)?.toHome()
    }

    @objc
    func restartGame() {
        (presentingViewController as? UINavigationController)?.restart()
    }

}
extension UINavigationController {

    func dismiss() {
        let popup = self.presentedViewController
        self.popViewController(animated: false)
        popup?.dismiss(animated: false, completion: nil)
    }

    func toHome() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let window = UIApplication.shared.keyWindow
        let root = window?.rootViewController
        let transition = getTransition()
        window?.layer.add(transition, forKey: nil)
        window?.rootViewController = viewController
        afterTransition {
            self.afterTransition {
                self.dismiss()
                self.afterTransition {
                    let transition = self.getTransition()
                    window?.layer.add(transition, forKey: nil)
                    window?.rootViewController = root
                }
            }
        }
    }

    func restart() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let window = UIApplication.shared.keyWindow
        let root = window?.rootViewController
        let transition = getTransition()
        window?.layer.add(transition, forKey: nil)
        window?.rootViewController = viewController
        afterTransition {
            self.afterTransition {
                self.dismiss()
                self.play(with: root)
                self.afterTransition {
                    let transition = self.getTransition()
                    window?.layer.add(transition, forKey: nil)
                    window?.rootViewController = root
                }
            }
        }
    }

    private func play(with controller: UIViewController?) {
        ((controller as? UINavigationController)?
            .viewControllers.first as? HomeScreenViewController)?
            .play()
    }

    private func afterTransition(block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            block()
        }
    }

    private func getTransition() -> CATransition {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        return transition
    }
}

enum GameType {
    case training
    case real
}
