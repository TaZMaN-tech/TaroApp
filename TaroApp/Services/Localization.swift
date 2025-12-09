//
//  Localization.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

//
//  Localization.swift
//  TaroApp
//

import Foundation

enum L10n {
    
    /// Основной метод для получения локализованной строки
    static func tr(_ key: String, comment: String = "") -> String {
        // Берём настройки пользователя
        let settings = StorageService.shared.getUserSettings()
        let language = settings.language
        
        // Определяем код языка
        let code: String
        switch language {
        case .system:
            // Используем первый язык системы (ru / en)
            let systemCode = Locale.preferredLanguages.first ?? "ru"
            code = systemCode.hasPrefix("ru") ? "ru" : "en"
        case .ru:
            code = "ru"
        case .en:
            code = "en"
        }
        
        // Находим нужный .lproj
        let bundle: Bundle
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let b = Bundle(path: path) {
            bundle = b
        } else {
            bundle = .main
        }
        
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: comment)
    }
}
