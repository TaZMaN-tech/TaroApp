//
//  PredictionManager.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 31.03.2025.
//

import Foundation
import UIKit

class PredictionManager {
    var cards: [TaroCard] = []

    func drawCards() {
        cards = TaroCard.drawThreeCards()
    }

    func generatePrompt(name: String, prediction: String) -> String {
        let resultString = cards.map { $0.description }.joined(separator: ", ")
        return """
        Привет! Меня зовут \(name).
        Расскажи \(prediction) по 3 картам Таро \(resultString), сделай ответ кратким и учитывай в ответе перевернута карта или нет.
        """
    }

    func callDeepseekAPI(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let apiKey = "sk-90ccc7b9833a4af89868d6248e2d1ea6"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 500
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let errorInfo = json?["error"] as? [String: Any],
                   let errorMessage = errorInfo["message"] as? String {
                    completion(.failure(NSError(domain: "APIError", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }

                if let choices = json?["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: -4, userInfo: nil)))
                }

            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
