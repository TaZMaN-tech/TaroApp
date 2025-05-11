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
        let greeting = String(format: NSLocalizedString("prompt_greeting", comment: ""), name)
        let summary = String(format: NSLocalizedString("prompt_summary", comment: ""), name, prediction, resultString)
        let card1 = NSLocalizedString("prompt_card1", comment: "")
        let card2 = NSLocalizedString("prompt_card2", comment: "")
        let card3 = NSLocalizedString("prompt_card3", comment: "")
        let ending = NSLocalizedString("prompt_ending", comment: "")

        return """
        \(greeting)
        \(summary)

        \(card1)
        \(card2)
        \(card3)

        \(ending)
        """
    }

    func callDeepseekAPI(cards: [String], name: String, subject: String, lang: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://taroapp-back.onrender.com/tarot?ver=0.1") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "cards": cards,
            "name": name,
            "lang": lang,
            "subject": subject
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 Отправляемое тело запроса:\n\(jsonString)")
            }
            request.httpBody = jsonData
        } catch {
            print("❌ Ошибка сериализации JSON: \(error)")
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("🔍 Ответ от сервера: \(responseString)")
            } else {
                print("⚠️ Не удалось преобразовать данные в строку")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let content = json?["content"] as? String {
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
