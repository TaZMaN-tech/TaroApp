//
//  ThemeManager.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import UIKit

final class ThemeManager {
    
    static let shared = ThemeManager()
    
    private let storageService: StorageServiceProtocol
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
    }
    
    var isDarkMode: Bool {
        get {
            storageService.getUserSettings().isDarkMode
        }
        set {
            var settings = storageService.getUserSettings()
            settings.isDarkMode = newValue
            storageService.saveUserSettings(settings)
            applyTheme()
        }
    }
    
    func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = style
        }
    }
}
