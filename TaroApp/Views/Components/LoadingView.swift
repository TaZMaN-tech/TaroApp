//
//  LoadingView.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class LoadingView: UIView {
    
    // MARK: - UI Elements
    
    private let gradientLayer = CAGradientLayer()
    private let cardContainer = UIView()
    private let animationImageView = UIImageView()
    private let tipLabel = UILabel()
    private var tipTimer: Timer?
    private var starsTimer: Timer?
    
    private let tips = [
        "🔮 Карты раскрывают тайны...",
        "✨ Звёзды выстраиваются...",
        "🌙 Луна шепчет ответы...",
        "🃏 Судьба тасует карты...",
        "🌟 Вселенная готовит послание..."
    ]
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupGradient()
        setupUI()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 125/255, green: 207/255, blue: 235/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 184/255, blue: 108/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        // Card container с рамкой и свечением
        cardContainer.layer.borderColor = UIColor(red: 240/255, green: 160/255, blue: 80/255, alpha: 1).cgColor
        cardContainer.layer.borderWidth = 4
        cardContainer.layer.cornerRadius = Design.CornerRadius.medium
        cardContainer.layer.shadowColor = UIColor.systemPink.cgColor
        cardContainer.layer.shadowOpacity = 0.8
        cardContainer.layer.shadowRadius = 20
        cardContainer.layer.shadowOffset = .zero
        cardContainer.layer.masksToBounds = false
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardContainer)
        
        // ImageView для анимации карт
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.clipsToBounds = true
        animationImageView.layer.cornerRadius = Design.CornerRadius.medium
        animationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let placeholderImage = UIImage(named: "card_back") {
            animationImageView.image = placeholderImage
        } else if let firstCard = TarotDeck.allCards.first,
                  let firstImage = UIImage(named: firstCard) {
            animationImageView.image = firstImage
        }
        
        cardContainer.addSubview(animationImageView)
        
        // Подсказка
        tipLabel.text = tips.randomElement()
        tipLabel.textColor = UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 1.0)
        tipLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            cardContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardContainer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            cardContainer.widthAnchor.constraint(equalToConstant: 200),
            cardContainer.heightAnchor.constraint(equalToConstant: 300),
            
            animationImageView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            animationImageView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            animationImageView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            animationImageView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            
            tipLabel.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 30),
            tipLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tipLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Animations
    
    func startAnimations() {
        startGradientAnimation()
        startImageAnimation()
        startAnimatingTips()
        spawnFloatingStars()
        addGlowAnimation()
    }
    
    func stopAnimations() {
        gradientLayer.removeAllAnimations()
        cardContainer.layer.removeAllAnimations()
        animationImageView.stopAnimating()
        tipTimer?.invalidate()
        tipTimer = nil
        starsTimer?.invalidate()
        starsTimer = nil
    }
    
    private func startGradientAnimation() {
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = gradientLayer.colors
        colorAnimation.toValue = [
            UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1).cgColor,
            UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1).cgColor,
            UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 1.0, green: 0.95, blue: 1.0, alpha: 1).cgColor
        ]
        colorAnimation.duration = 3
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        colorAnimation.fillMode = .forwards
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(colorAnimation, forKey: "colorChange")
    }
    
    private func startImageAnimation() {
        let images = TarotDeck.allCards.compactMap { UIImage(named: $0) }
        
        guard !images.isEmpty else {
            print("⚠️ No card images found!")
            return
        }
        
        animationImageView.image = images.first
        
        animationImageView.animationImages = images
        animationImageView.animationDuration = Double(images.count) * 0.7
        animationImageView.startAnimating()
    }
    
    private func startAnimatingTips() {
        tipTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            UIView.transition(with: self.tipLabel, duration: 0.5, options: .transitionCrossDissolve) {
                self.tipLabel.text = self.tips.randomElement()
            }
        }
    }
    
    private func spawnFloatingStars() {
        starsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let star = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...self.bounds.width),
                y: self.bounds.height,
                width: 6,
                height: 6
            ))
            star.backgroundColor = .white
            star.layer.cornerRadius = 3
            star.alpha = 0.8
            self.addSubview(star)
            self.bringSubviewToFront(self.tipLabel)
            
            UIView.animate(withDuration: Double.random(in: 4...7), delay: 0, options: .curveLinear) {
                star.frame.origin.y = -10
                star.alpha = 0
            } completion: { _ in
                star.removeFromSuperview()
            }
        }
    }
    
    private func addGlowAnimation() {
        let animation = CABasicAnimation(keyPath: "shadowRadius")
        animation.fromValue = 5
        animation.toValue = 25
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        cardContainer.layer.add(animation, forKey: "glowPulse")
    }
    
    deinit {
        stopAnimations()
    }
}
