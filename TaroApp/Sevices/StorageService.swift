//
//  PredictionManager.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 31.03.2025.
//

import Foundation

// MARK: - Protocol

protocol StorageServiceProtocol {
    func savePrediction(_ prediction: Prediction)
    func getAllPredictions() -> [Prediction]
    func getFavoritePredictions() -> [Prediction]
    func deletePrediction(id: UUID)
    func toggleFavorite(id: UUID)
    func clearHistory()
    func getUserSettings() -> UserSettings
    func saveUserSettings(_ settings: UserSettings)
}

// MARK: - Implementation

final class StorageService: StorageServiceProtocol {
    
    static let shared = StorageService()
    
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private enum Keys {
        static let predictions = "saved_predictions"
        static let userSettings = "user_settings"
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Predictions
    
    func savePrediction(_ prediction: Prediction) {
        var predictions = getAllPredictions()
        predictions.insert(prediction, at: 0)
        
        if predictions.count > 100 {
            predictions = Array(predictions.prefix(100))
        }
        
        save(predictions, forKey: Keys.predictions)
    }
    
    func getAllPredictions() -> [Prediction] {
        load([Prediction].self, forKey: Keys.predictions) ?? []
    }
    
    func getFavoritePredictions() -> [Prediction] {
        getAllPredictions().filter { $0.isFavorite }
    }
    
    func deletePrediction(id: UUID) {
        var predictions = getAllPredictions()
        predictions.removeAll { $0.id == id }
        save(predictions, forKey: Keys.predictions)
    }
    
    func toggleFavorite(id: UUID) {
        var predictions = getAllPredictions()
        if let index = predictions.firstIndex(where: { $0.id == id }) {
            predictions[index].isFavorite.toggle()
            save(predictions, forKey: Keys.predictions)
        }
    }
    
    func clearHistory() {
        let favorites = getFavoritePredictions()
        save(favorites, forKey: Keys.predictions)
    }
    
    // MARK: - User Settings
    
    func getUserSettings() -> UserSettings {
        load(UserSettings.self, forKey: Keys.userSettings) ?? .default
    }
    
    func saveUserSettings(_ settings: UserSettings) {
        save(settings, forKey: Keys.userSettings)
    }
    
    // MARK: - Private Helpers
    
    private func save<T: Encodable>(_ object: T, forKey key: String) {
        do {
            let data = try encoder.encode(object)
            defaults.set(data, forKey: key)
        } catch {
            print("❌ Failed to save \(key): \(error)")
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ Failed to load \(key): \(error)")
            return nil
        }
    }
}
