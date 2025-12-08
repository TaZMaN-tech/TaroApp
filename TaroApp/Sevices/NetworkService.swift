//
//  File.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import Foundation

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .noData: return "Нет данных"
        case .decodingError: return "Ошибка декодирования"
        case .serverError(let code): return "Ошибка сервера: \(code)"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

// MARK: - API Models

struct BackendRequest: Codable {
    let cards: [String]
    let name: String
    let lang: String
    let subject: String
}

struct BackendResponse: Codable {
    let content: String
}

// MARK: - Protocol

protocol NetworkServiceProtocol {
    func getPrediction(
        cards: [TarotCard],
        name: String,
        spreadType: SpreadType,
        language: String
    ) async throws -> String
}

// MARK: - Implementation

final class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    private let baseURL = "https://taroapp-back.onrender.com"
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }
    
    func getPrediction(
        cards: [TarotCard],
        name: String,
        spreadType: SpreadType,
        language: String
    ) async throws -> String {
        
        guard let url = URL(string: "\(baseURL)/tarot?ver=0.1") else {
            throw NetworkError.invalidURL
        }
        
        let request = BackendRequest(
            cards: cards.map { $0.name },
            name: name,
            lang: language,
            subject: spreadType.title
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let backendResponse = try decoder.decode(BackendResponse.self, from: data)
        return backendResponse.content
    }
}

// MARK: - Mock для тестов и превью

final class MockNetworkService: NetworkServiceProtocol {
    
    var delay: TimeInterval = 2.0
    var shouldFail = false
    
    func getPrediction(
        cards: [TarotCard],
        name: String,
        spreadType: SpreadType,
        language: String
    ) async throws -> String {
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldFail {
            throw NetworkError.networkError(NSError(domain: "Mock", code: -1))
        }
        
        return """
        🔮 **\(cards[0].name)** — Эта карта говорит о новых начинаниях. \(cards[0].isReversed ? "В перевёрнутом положении предупреждает об осторожности." : "Время действовать!")
        
        🌟 **\(cards[1].name)** — Символизирует внутреннюю мудрость. \(cards[1].isReversed ? "Прислушайся к интуиции." : "Доверяй своим чувствам.")
        
        ✨ **\(cards[2].name)** — Карта трансформации. \(cards[2].isReversed ? "Перемены могут быть непростыми." : "Впереди позитивные изменения.")
        
        💫 **Вывод для \(name):** Карты показывают период роста. Доверяй процессу!
        """
    }
}
