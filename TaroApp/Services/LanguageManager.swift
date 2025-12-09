//
//  LanguageManager.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import Foundation

final class LanguageManager {

    static let shared = LanguageManager()

    private let storage: StorageServiceProtocol

    private enum Keys {
        static let appleLanguages = "AppleLanguages"
    }

    private init(storage: StorageServiceProtocol = StorageService.shared) {
        self.storage = storage
    }

    var currentLanguage: AppLanguage {
        get { storage.getUserSettings().language }
        set {
            var settings = storage.getUserSettings()
            settings.language = newValue
            storage.saveUserSettings(settings)
            applyLanguage(newValue)
        }
    }

    func applyCurrentLanguageOnLaunch() {
        applyLanguage(currentLanguage)
    }

    private func applyLanguage(_ language: AppLanguage) {
        switch language {
        case .system:
            // Убираем кастомную настройку — система сама выберет язык
            UserDefaults.standard.removeObject(forKey: Keys.appleLanguages)
        case .ru:
            UserDefaults.standard.set(["ru", "en"], forKey: Keys.appleLanguages)
        case .en:
            UserDefaults.standard.set(["en", "ru"], forKey: Keys.appleLanguages)
        }
        UserDefaults.standard.synchronize()
    }
}
