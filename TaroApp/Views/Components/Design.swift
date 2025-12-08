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
        static let textPrimary = UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 1)
        static let textSecondary = UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 0.7)
        static let background = UIColor.white
        
        static let gradientStart = UIColor(red: 125/255, green: 207/255, blue: 235/255, alpha: 1)
        static let gradientEnd = UIColor(red: 255/255, green: 184/255, blue: 108/255, alpha: 1)
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
