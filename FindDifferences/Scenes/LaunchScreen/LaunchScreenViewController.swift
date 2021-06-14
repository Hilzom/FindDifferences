//
//  LaunchScreenViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

//final class LaunchScreenViewController: UIViewController, AppearanceDelegate {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        configureColors()
//
//        let label = UILabel()
//        label.text = "Сюда нужна гифка"
//        label.textAlignment = .center
//        label.embedView(to: view)
//        Appearance.add(self)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(.zero)) { [weak self] in
//            self?.routeToHome()
//        }
//    }
//
//    func configureColors() {
//        view.backgroundColor = Colors.bgColor
//    }
//
//    private func routeToHome() {
//        guard let window = UIApplication.shared.keyWindow else { return }
//        let home = HomeScreenViewController()
//        let presenter = HomePresenter(rootViewController: home)
//        window.rootViewController = presenter
//        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
//    }
//}
