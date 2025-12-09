//
//  Design.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

enum Design {
    
    // MARK: - Colors
    
    enum Colors {
        // Динамические цвета с поддержкой тёмной темы
        static var textPrimary: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                    : UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 1)
            }
        }
        
        static var textSecondary: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
                    : UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 0.7)
            }
        }
        
        static var background: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
                    : .white
            }
        }
        
        static var cardBackground: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
                    : .white
            }
        }
        
        static var separator: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
                    : UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            }
        }
        
        // Градиенты (адаптивные + время суток)
        static var gradientStart: UIColor {
            UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return TimeBasedGradients.shared.darkStart
                } else {
                    return TimeBasedGradients.shared.lightStart
                }
            }
        }
        
        static var gradientEnd: UIColor {
            UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return TimeBasedGradients.shared.darkEnd
                } else {
                    return TimeBasedGradients.shared.lightEnd
                }
            }
        }
        
        // Для таблиц
        static var cellBackground: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 35/255, green: 35/255, blue: 38/255, alpha: 1)
                    : UIColor.white
            }
        }
        
        static var groupedBackground: UIColor {
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
                    : UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
            }
        }
    }
    
    // MARK: - Fonts
    
    enum Fonts {
        static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .medium)
        static let small = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
    }
}
