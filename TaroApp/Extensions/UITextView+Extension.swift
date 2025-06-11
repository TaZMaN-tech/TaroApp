//
//  UITextView+Extension.swift
//  Login App
//
//  Created by Тадевос Курдоглян on 20.03.2025.
//

import UIKit

extension UITextView {
    func setBoldText(from text: String, baseFontSize: CGFloat = 17) {
        let baseFont = UIFont.systemFont(ofSize: baseFontSize)
        let boldFont = UIFont.boldSystemFont(ofSize: baseFontSize)
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: baseFont])
        let pattern = "\\*\\*(.*?)\\*\\*"  // Регулярка для двойных звёздочек **текст**

        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches.reversed() {  // Обязательно с конца
                let boldRange = match.range(at: 1)   // Внутренний текст между **
                let fullRange = match.range(at: 0)   // Вся **обёрнутая** часть

                // Выдёргиваем сам текст без звёздочек
                let boldText = (text as NSString).substring(with: boldRange)

                // Заменяем **text** на просто text
                attributedString.replaceCharacters(in: fullRange, with: boldText)

                // Назначаем жирный стиль на новый диапазон
                attributedString.addAttribute(.font,
                                              value: boldFont,
                                              range: NSRange(location: fullRange.location, length: boldText.count))
            }
        }

        self.attributedText = attributedString
    }
}
