//
//  AppDelegate.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeProducts()
        initializeWindowIfNeeded()
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func initializeWindowIfNeeded() {
        guard !GlobalConstants.is13iOSorHigher else { return }
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)

        let home = HomeScreenViewController()
        let presenter = HomePresenter(rootViewController: home)
        window?.rootViewController = presenter
        window?.makeKeyAndVisible()
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }

    static func fatalErrorIfDebug() {
        #if DEBUG
        fatalError()
        #endif
    }

    private func initializeProducts() {
        AppStoreManager.shared.validate(productIdentifiers: ["differences.premium.forever"])
    }
}

