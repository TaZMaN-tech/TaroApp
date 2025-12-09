//
//  GradientButton.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    private let iconLabel = UILabel()
    private let titleLbl = UILabel()
    
    var gradientColors: (start: UIColor, end: UIColor) = (Design.Colors.gradientStart, Design.Colors.gradientEnd) {
        didSet { updateGradient() }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                self.alpha = self.isHighlighted ? 0.85 : 1.0
                self.layer.shadowOpacity = self.isHighlighted ? 0.25 : 0.15
                self.layer.shadowRadius = self.isHighlighted ? 12 : 4
            }
            
            if isHighlighted {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Настраиваем layer для тени
        layer.cornerRadius = Design.CornerRadius.medium
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        
        // Градиент с клипингом
        gradientLayer.cornerRadius = Design.CornerRadius.medium
        gradientLayer.masksToBounds = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        
        iconLabel.font = UIFont.systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        titleLbl.font = Design.Fonts.caption
        titleLbl.textColor = .white
        titleLbl.textAlignment = .center
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLbl)
        
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            titleLbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLbl.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4)
        ])
        
        updateGradient()
    }
    
    func configure(icon: String, title: String, colors: (start: UIColor, end: UIColor)) {
        iconLabel.text = icon
        titleLbl.text = title
        gradientColors = colors
    }
    
    private func updateGradient() {
        gradientLayer.colors = [gradientColors.start.cgColor, gradientColors.end.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
