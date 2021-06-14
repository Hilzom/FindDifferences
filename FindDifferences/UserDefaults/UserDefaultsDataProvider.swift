//
//  UserDefaultsDataProvider.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import Foundation

private enum UserDefaultsKeys: String {
    case currentLevel
    case isSoundsActive
    case isMusicActive
    case isVibrationsActive
    case isPremium
    case isDarkMode
}


final class UserDefaultsDataProvider {

    private static let userDefaults = UserDefaults()

    static var isPremium: Bool {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.isPremium.rawValue) as? Bool ?? false
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.isPremium.rawValue)
        }
    }

    static var currentLevel: Int {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.currentLevel.rawValue) as? Int ?? 1
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.currentLevel.rawValue)
        }
    }

    static var isSoundsActive: Bool {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.isSoundsActive.rawValue) as? Bool ?? true
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.isSoundsActive.rawValue)
        }
    }

    static var isMusicActive: Bool {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.isMusicActive.rawValue) as? Bool ?? true
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.isMusicActive.rawValue)
        }
    }

    static var isVibrationsActive: Bool {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.isVibrationsActive.rawValue) as? Bool ?? true
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.isVibrationsActive.rawValue)
        }
    }

    static var isDarkModeActive: Bool {
        get {
            userDefaults.value(forKey: UserDefaultsKeys.isDarkMode.rawValue) as? Bool ?? false
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsKeys.isDarkMode.rawValue)
        }
    }

    static func toggleSwitch(with name: String) {
        switch name {
        case "Звуки":
            UserDefaultsDataProvider.isSoundsActive = !UserDefaultsDataProvider.isSoundsActive

        case "Музыка":
            UserDefaultsDataProvider.isMusicActive = !UserDefaultsDataProvider.isMusicActive

        case "Вибрация":
            UserDefaultsDataProvider.isVibrationsActive = !UserDefaultsDataProvider.isVibrationsActive

        case "Тёмная тема":
            UserDefaultsDataProvider.isDarkModeActive = !UserDefaultsDataProvider.isDarkModeActive
            Appearance.updateTheme()

        default: AppDelegate.fatalErrorIfDebug()
        }
    }

    static func getSwitchValue(with name: String) -> Bool {
        switch name {
        case "Звуки":
            return UserDefaultsDataProvider.isSoundsActive

        case "Музыка":
            return UserDefaultsDataProvider.isMusicActive

        case "Вибрация":
            return UserDefaultsDataProvider.isVibrationsActive

        default: AppDelegate.fatalErrorIfDebug(); return true
        }
    }
}
