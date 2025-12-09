//
//  TimeBasedGradients.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import UIKit

/// Динамические градиенты в зависимости от времени суток
final class TimeBasedGradients {
    
    static let shared = TimeBasedGradients()
    
    private init() {}
    
    /// Цвета для светлой темы (зависят от времени суток)
    var lightStart: UIColor {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<8:  // Рассвет 🌅
            return UIColor(red: 255/255, green: 183/255, blue: 77/255, alpha: 1)
        case 8..<12:  // Утро ☀️
            return UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1)
        case 12..<17: // День 🌤
            return UIColor(red: 100/255, green: 181/255, blue: 246/255, alpha: 1)
        case 17..<20: // Вечер 🌇
            return UIColor(red: 255/255, green: 167/255, blue: 38/255, alpha: 1)
        case 20..<23: // Сумерки 🌆
            return UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1)
        default:      // Ночь 🌙
            return UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        }
    }
    
    var lightEnd: UIColor {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<8:  // Рассвет 🌅
            return UIColor(red: 255/255, green: 138/255, blue: 101/255, alpha: 1)
        case 8..<12:  // Утро ☀️
            return UIColor(red: 255/255, green: 245/255, blue: 157/255, alpha: 1)
        case 12..<17: // День 🌤
            return UIColor(red: 187/255, green: 222/255, blue: 251/255, alpha: 1)
        case 17..<20: // Вечер 🌇
            return UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
        case 20..<23: // Сумерки 🌆
            return UIColor(red: 103/255, green: 58/255, blue: 183/255, alpha: 1)
        default:      // Ночь 🌙
            return UIColor(red: 26/255, green: 35/255, blue: 126/255, alpha: 1)
        }
    }
    
    /// Цвета для тёмной темы (более мягкие, приглушённые)
    var darkStart: UIColor {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<8:  // Рассвет 🌅
            return UIColor(red: 120/255, green: 85/255, blue: 60/255, alpha: 1)
        case 8..<12:  // Утро ☀️
            return UIColor(red: 50/255, green: 90/255, blue: 110/255, alpha: 1)
        case 12..<17: // День 🌤
            return UIColor(red: 40/255, green: 80/255, blue: 120/255, alpha: 1)
        case 17..<20: // Вечер 🌇
            return UIColor(red: 110/255, green: 70/255, blue: 50/255, alpha: 1)
        case 20..<23: // Сумерки 🌆
            return UIColor(red: 80/255, green: 40/255, blue: 100/255, alpha: 1)
        default:      // Ночь 🌙
            return UIColor(red: 30/255, green: 40/255, blue: 80/255, alpha: 1)
        }
    }
    
    var darkEnd: UIColor {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<8:  // Рассвет 🌅
            return UIColor(red: 140/255, green: 70/255, blue: 80/255, alpha: 1)
        case 8..<12:  // Утро ☀️
            return UIColor(red: 80/255, green: 110/255, blue: 100/255, alpha: 1)
        case 12..<17: // День 🌤
            return UIColor(red: 70/255, green: 100/255, blue: 130/255, alpha: 1)
        case 17..<20: // Вечер 🌇
            return UIColor(red: 130/255, green: 50/255, blue: 70/255, alpha: 1)
        case 20..<23: // Сумерки 🌆
            return UIColor(red: 60/255, green: 40/255, blue: 90/255, alpha: 1)
        default:      // Ночь 🌙
            return UIColor(red: 20/255, green: 30/255, blue: 60/255, alpha: 1)
        }
    }
    
    /// Время суток текстом (для отладки)
    var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<8:  return "🌅 Рассвет"
        case 8..<12:  return "☀️ Утро"
        case 12..<17: return "🌤 День"
        case 17..<20: return "🌇 Вечер"
        case 20..<23: return "🌆 Сумерки"
        default:      return "🌙 Ночь"
        }
    }
}
