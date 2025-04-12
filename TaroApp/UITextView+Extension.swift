//
//  UITextView+Extension.swift
//  Login App
//
//  Created by Тадевос Курдоглян on 20.03.2025.
//

import UIKit

extension UITextView {
    func setBoldText(from text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        let pattern = "\\*(.*?)\\*"  // Ищем всё между *

        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches.reversed() {  // Важно идти с конца
                let boldRange = match.range(at: 1)   // Внутренний текст между *
                let fullRange = match.range(at: 0)   // Вся *обёрнутая* часть

                // Достаём сам текст без звёздочек
                let boldText = (text as NSString).substring(with: boldRange)

                // Заменяем *text* на просто text
                attributedString.replaceCharacters(in: fullRange, with: boldText)

                // Назначаем жирный стиль на новую позицию текста
                attributedString.addAttribute(.font,
                                              value: UIFont.boldSystemFont(ofSize: self.font?.pointSize ?? 17),
                                              range: NSRange(location: fullRange.location, length: boldText.count))
            }
        }

        self.attributedText = attributedString
    }
}
