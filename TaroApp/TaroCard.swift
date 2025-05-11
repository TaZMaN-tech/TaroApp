//
//  TaroCard.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 20.03.2025.
//

import Foundation


struct TaroCard {
    let name: String
    let rotation: Bool
    var comment: String {
        if rotation {
            return "перевернутая"
        } else {
           return "не перевернутая"
        }
    }
    var description: String {
        "\(name) - \(comment)"
    }
    
    static func drawThreeCards() -> [TaroCard] {
            let randomNames = tarotCardNames.shuffled().prefix(3)
            return randomNames.map { name in
                TaroCard(name: name, rotation: Bool.random())
            }
        }
}

private let tarotCardNames = [
    "Ten of Pentacles", "Queen of Wands", "Page of Wands", "Knight of Wands", "King of Wands", "Ace of Wands",
    "Ten of Wands", "Nine of Wands", "Eight of Wands", "Seven of Wands", "Six of Wands", "Five of Wands",
    "Four of Wands", "Three of Wands", "Two of Wands", "Queen of Swords", "Page of Swords", "Knight of Swords",
    "King of Swords", "Ace of Swords", "Ten of Swords", "Nine of Swords", "Eight of Swords", "Seven of Swords",
    "Six of Swords", "Five of Swords", "Four of Swords", "Three of Swords", "Two of Swords", "Queen of Pentacles",
    "Page of Pentacles", "Knight of Pentacles", "King of Pentacles", "Ace of Pentacles", "Nine of Pentacles",
    "Eight of Pentacles", "Seven of Pentacles", "Six of Pentacles", "Five of Pentacles", "Four of Pentacles",
    "Three of Pentacles", "Two of Pentacles", "Queen of Cups", "Page of Cups", "Knight of Cups", "King of Cups",
    "Ace of Cups", "Ten of Cups", "Nine of Cups", "Eight of Cups", "Seven of Cups", "Six of Cups", "Five of Cups",
    "Four of Cups", "Three of Cups", "Two of Cups", "The World", "Judgement", "The Sun", "The Moon", "The Star",
    "The Tower", "The Devil", "Temperance", "Death", "The Hanged Man", "Justice",
    "The Wheel of Fortune", "The Hermit", "Strength", "The Chariot", "The Lovers", "The Hierophant",
    "The Emperor", "The Empress", "The High Priestess", "The Magician", "The Fool"
]
