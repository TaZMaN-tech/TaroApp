//
//  TaroCard.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 20.03.2025.
//

import UIKit

enum AppLanguage: String, Codable, CaseIterable {
    case system
    case ru
    case en
    
    var title: String {
        switch self {
        case .system: return L10n.tr("settings_language_system")
        case .ru:     return L10n.tr("settings_language_ru")
        case .en:     return L10n.tr("settings_language_en")
        }
    }
    
    /// Код для бэкенда
    var backendCode: String {
        switch self {
        case .system:
            // Берём первый предпочитаемый язык системы и маппим на ru/en
            let code = Locale.preferredLanguages.first ?? "ru"
            return code.hasPrefix("ru") ? "ru" : "en"
        case .ru:
            return "ru"
        case .en:
            return "en"
        }
    }
}

struct TarotCard: Codable, Identifiable {
    let id: UUID
    let name: String
    let isReversed: Bool
    
    var localizedName: String {
        CardLocalizer.localize(name)
    }
    
    var displayName: String {
        if isReversed {
            let format = L10n.tr("card_reversed_format") // "%@ (reversed)" / "%@ (перевёрнута)"
            return String(format: format, localizedName)
        } else {
            return localizedName
        }
    }
    
    var imageName: String {
        name
    }
    
    init(id: UUID = UUID(), name: String, isReversed: Bool = false) {
        self.id = id
        self.name = name
        self.isReversed = isReversed
    }
    
    static func randomCards(count: Int = 3) -> [TarotCard] {
        TarotDeck.allCards
            .shuffled()
            .prefix(count)
            .map { TarotCard(name: $0, isReversed: Bool.random()) }
    }
}

// MARK: - Tarot Deck

enum TarotDeck {
    static let allCards: [String] = [
        // Major Arcana
        "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
        "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
        "The Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
        "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World",
        
        // Wands
        "Ace of Wands", "Two of Wands", "Three of Wands", "Four of Wands", "Five of Wands",
        "Six of Wands", "Seven of Wands", "Eight of Wands", "Nine of Wands", "Ten of Wands",
        "Page of Wands", "Knight of Wands", "Queen of Wands", "King of Wands",
        
        // Cups
        "Ace of Cups", "Two of Cups", "Three of Cups", "Four of Cups", "Five of Cups",
        "Six of Cups", "Seven of Cups", "Eight of Cups", "Nine of Cups", "Ten of Cups",
        "Page of Cups", "Knight of Cups", "Queen of Cups", "King of Cups",
        
        // Swords
        "Ace of Swords", "Two of Swords", "Three of Swords", "Four of Swords", "Five of Swords",
        "Six of Swords", "Seven of Swords", "Eight of Swords", "Nine of Swords", "Ten of Swords",
        "Page of Swords", "Knight of Swords", "Queen of Swords", "King of Swords",
        
        // Pentacles
        "Ace of Pentacles", "Two of Pentacles", "Three of Pentacles", "Four of Pentacles", "Five of Pentacles",
        "Six of Pentacles", "Seven of Pentacles", "Eight of Pentacles", "Nine of Pentacles", "Ten of Pentacles",
        "Page of Pentacles", "Knight of Pentacles", "Queen of Pentacles", "King of Pentacles"
    ]
}

// MARK: - Spread Type

enum SpreadType: String, CaseIterable, Codable {
    case love
    case career
    case dayCard
    case future
    case harmony
    case health
    case karma
    case vacation
    
    var title: String {
        switch self {
        case .love:     return L10n.tr("love_button")
        case .career:   return L10n.tr("job_button")
        case .dayCard:  return L10n.tr("day_button")
        case .future:   return L10n.tr("future_button")
        case .harmony:  return L10n.tr("self_button")
        case .health:   return L10n.tr("health_button")
        case .karma:    return L10n.tr("karma_button")
        case .vacation: return L10n.tr("vacation_button")
        }
    }
    
    var icon: String {
        switch self {
        case .love: return "❤️"
        case .career: return "💼"
        case .dayCard: return "🌞"
        case .future: return "🔮"
        case .harmony: return "🧘"
        case .health: return "🩺"
        case .karma: return "✨"
        case .vacation: return "🏖️"
        }
    }
    
    var gradientColors: (start: UIColor, end: UIColor) {
        switch self {
        case .love:
            return (UIColor(red: 230/255, green: 110/255, blue: 120/255, alpha: 1),
                    UIColor(red: 240/255, green: 160/255, blue: 80/255, alpha: 1))
        case .career:
            return (UIColor(red: 60/255, green: 100/255, blue: 140/255, alpha: 1),
                    UIColor(red: 185/255, green: 140/255, blue: 70/255, alpha: 1))
        case .dayCard:
            return (UIColor(red: 255/255, green: 200/255, blue: 40/255, alpha: 1),
                    UIColor(red: 245/255, green: 160/255, blue: 60/255, alpha: 1))
        case .future:
            return (UIColor(red: 120/255, green: 210/255, blue: 235/255, alpha: 1),
                    UIColor(red: 135/255, green: 180/255, blue: 210/255, alpha: 1))
        case .harmony:
            return (UIColor(red: 80/255, green: 150/255, blue: 60/255, alpha: 1),
                    UIColor(red: 145/255, green: 210/255, blue: 145/255, alpha: 1))
        case .health:
            return (UIColor(red: 200/255, green: 130/255, blue: 30/255, alpha: 1),
                    UIColor(red: 255/255, green: 190/255, blue: 110/255, alpha: 1))
        case .karma:
            return (UIColor(red: 70/255, green: 200/255, blue: 215/255, alpha: 1),
                    UIColor(red: 100/255, green: 180/255, blue: 210/255, alpha: 1))
        case .vacation:
            return (UIColor(red: 180/255, green: 120/255, blue: 200/255, alpha: 1),
                    UIColor(red: 220/255, green: 160/255, blue: 180/255, alpha: 1))
        }
    }
}

// MARK: - Prediction

struct Prediction: Codable, Identifiable {
    let id: UUID
    let userName: String
    let spreadType: SpreadType
    let cards: [TarotCard]
    let text: String
    let createdAt: Date
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        userName: String,
        spreadType: SpreadType,
        cards: [TarotCard],
        text: String,
        createdAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.userName = userName
        self.spreadType = spreadType
        self.cards = cards
        self.text = text
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

// MARK: - User Settings

struct UserSettings: Codable {
    var userName: String
    var hasSeenOnboarding: Bool
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var language: AppLanguage
    
    var hasUserName: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static var `default`: UserSettings {
        UserSettings(
            userName: "",
            hasSeenOnboarding: false,
            isDarkMode: false,
            notificationsEnabled: false,
            language: .system
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userName
        case hasSeenOnboarding
        case isDarkMode
        case notificationsEnabled
        case language
    }
    
    init(
        userName: String,
        hasSeenOnboarding: Bool,
        isDarkMode: Bool,
        notificationsEnabled: Bool,
        language: AppLanguage
    ) {
        self.userName = userName
        self.hasSeenOnboarding = hasSeenOnboarding
        self.isDarkMode = isDarkMode
        self.notificationsEnabled = notificationsEnabled
        self.language = language
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        hasSeenOnboarding = try container.decode(Bool.self, forKey: .hasSeenOnboarding)
        isDarkMode = try container.decode(Bool.self, forKey: .isDarkMode)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .system
    }
}

// MARK: - Loading State

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

