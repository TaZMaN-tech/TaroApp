//
//  LanguageManager.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import Foundation

final class LanguageManager {
    
    static let shared = LanguageManager()
    
    var currentLanguage: AppLanguage {
        get {
            StorageService.shared.getUserSettings().language
        }
        set {
            var settings = StorageService.shared.getUserSettings()
            settings.language = newValue
            StorageService.shared.saveUserSettings(settings)
        }
    }
    
    private init() {}
}
