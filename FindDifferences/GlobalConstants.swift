//
//  GlobalConstants.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit.UIColor
import AVFoundation

enum GlobalConstants {

    static let is13iOSorHigher: Bool = {
        guard #available(iOS 13.0, *) else { return false }
        return true
    }()
    static let horizontalSpacing: CGFloat = 16
}

enum Colors {
    private static var appearance: Appearance.InterfaceStyle {
        return Appearance.currentTheme
    }
    static var bgColor: UIColor {
        switch appearance {
        case .dark: return .init(white: 0.08, alpha: 1)
        case .light: return .white
        }
    }

    static var textColor: UIColor {
        switch appearance {
        case .dark: return .white
        case .light: return .black
        }
    }

    static var dividerColor: UIColor {
        switch appearance {
        case .dark: return .black
        case .light: return UIColor(rgb: 0xF2F2F7)
        }
    }
    
//    static let backgroundLight = UIColor.white
    static let blueColor = UIColor.systemBlue
    static let blurBgColor: UIColor = .black.withAlphaComponent(0.55)
}

final class Appearance {
    private(set) static var currentTheme: InterfaceStyle = .init(UserDefaultsDataProvider.isDarkModeActive)
    private static var delegates: [DelegateWrapper] = []

    static func updateTheme()  {
        currentTheme = InterfaceStyle(UserDefaultsDataProvider.isDarkModeActive)
        notifyDelegates()
    }
    static func add(_ delegate: AppearanceDelegate) {
        removeAllUseless()
        delegates.append(.init(delegate))
    }
    static func remove(_ delegate: AppearanceDelegate) {
        removeAllUseless()
        delegates.removeAll(where: { $0.delegate === delegate })
    }
    private static func removeAllUseless() {
        delegates.removeAll(where: { return $0.delegate == nil })
    }

    private static func notifyDelegates() {
        delegates.forEach { $0.delegate?.configureColors() }
    }

    enum InterfaceStyle {
        case dark
        case light

        init(_ isDark: Bool) {
            self = isDark ? .dark : .light
        }
    }
}

final class DelegateWrapper {
    weak var delegate: AppearanceDelegate?

    init(_ delegate: AppearanceDelegate) {
        self.delegate = delegate
    }
}
protocol AppearanceDelegate: AnyObject {
    func configureColors()
}

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    @available(iOS 13.0, *)
    case soft
    @available(iOS 13.0, *)
    case rigid
    case selection
    case oldSchool

    public func vibrate() {
        guard UserDefaultsDataProvider.isVibrationsActive else { return }
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
