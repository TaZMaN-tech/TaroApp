//
//  LoadingViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 25.03.2025.
//

import UIKit

class LoadingViewController: UIViewController {

    private let tipLabel = UILabel()
    private let cardContainer = UIView()
    private let animationImageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private var tipTimer: Timer?


    private let tips = [
        NSLocalizedString("tip_1", comment: ""),
        NSLocalizedString("tip_2", comment: ""),
        NSLocalizedString("tip_3", comment: ""),
        NSLocalizedString("tip_4", comment: ""),
        NSLocalizedString("tip_5", comment: "")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        startGradientAnimation()
        startAnimatingTips()
        startImageAnimation()
        spawnFloatingStars()
        addGlowAnimation(to: cardContainer)
    }

    private func setupGradient() {
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 125/255, green: 207/255, blue: 235/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 184/255, blue: 108/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
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

    private func setupUI() {
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.layer.borderColor = UIColor(red: 240/255, green: 160/255, blue: 80/255, alpha: 1).cgColor
        cardContainer.layer.borderWidth = 4
        cardContainer.layer.cornerRadius = 16
        cardContainer.layer.shadowColor = UIColor.systemPink.cgColor
        cardContainer.layer.shadowOpacity = 0.8
        cardContainer.layer.shadowRadius = 20
        cardContainer.layer.shadowOffset = .zero
        cardContainer.layer.masksToBounds = false
        view.addSubview(cardContainer)

        animationImageView.contentMode = .scaleAspectFill
        animationImageView.translatesAutoresizingMaskIntoConstraints = false
        animationImageView.clipsToBounds = true
        animationImageView.layer.cornerRadius = 16
        cardContainer.addSubview(animationImageView)

        tipLabel.text = NSLocalizedString("tip_loading", comment: "")
        tipLabel.textColor = UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 1.0)
        tipLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility settings
        tipLabel.accessibilityLabel = NSLocalizedString("loading_tip_accessibility", comment: "")
        tipLabel.adjustsFontForContentSizeCategory = true
        tipLabel.font = UIFont.preferredFont(forTextStyle: .headline)

        view.addSubview(tipLabel)

        NSLayoutConstraint.activate([
            cardContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            cardContainer.widthAnchor.constraint(equalToConstant: 200),
            cardContainer.heightAnchor.constraint(equalToConstant: 300),

            animationImageView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            animationImageView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            animationImageView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            animationImageView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            tipLabel.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 30),
            tipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func startAnimatingTips() {
        tipTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            UIView.transition(with: self.tipLabel, duration: 0.5, options: .transitionCrossDissolve) {
                self.tipLabel.text = self.tips.randomElement()
            }
        }
    }

    private func startImageAnimation() {
        let images = tarotCardNames.compactMap { UIImage(named: $0) }
        animationImageView.animationImages = images
        animationImageView.animationDuration = Double(images.count) * 0.7
        animationImageView.startAnimating()
    }

    private func spawnFloatingStars() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let star = UIView(frame: CGRect(x: CGFloat.random(in: 0...self.view.bounds.width),
                                            y: self.view.bounds.height,
                                            width: 6,
                                            height: 6))
            star.backgroundColor = .white
            star.layer.cornerRadius = 3
            star.alpha = 0.8
            self.view.addSubview(star)
            self.view.bringSubviewToFront(self.tipLabel)

            UIView.animate(withDuration: Double.random(in: 4...7), delay: 0, options: .curveLinear, animations: {
                star.frame.origin.y = -10
                star.alpha = 0
            }, completion: { _ in
                star.removeFromSuperview()
            })
        }
    }

    private func addGlowAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "shadowRadius")
        animation.fromValue = 5
        animation.toValue = 15
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        view.layer.add(animation, forKey: "glowPulse")
    }

    deinit {
        tipTimer?.invalidate()
    }
}
