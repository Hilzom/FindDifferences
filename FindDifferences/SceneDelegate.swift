//
//  SceneDelegate.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let home = HomeScreenViewController()
        let presenter = HomePresenter(rootViewController: home)
        window?.rootViewController = presenter
        window?.makeKeyAndVisible()
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
}

