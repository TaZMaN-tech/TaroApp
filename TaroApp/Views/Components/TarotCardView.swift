//
//  TarotCardView.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class TarotCardView: UIView {
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    
    var onTap: (() -> Void)?
    
    var card: TarotCard? {
        didSet { updateCard() }
    }
    
    var isFlipped: Bool = false {
        didSet { updateFlipState() }
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
        backgroundColor = Design.Colors.cardBackground
        layer.cornerRadius = Design.CornerRadius.small
        layer.borderWidth = 2
        layer.borderColor = Design.Colors.separator.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        clipsToBounds = false
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Design.CornerRadius.small - 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        nameLabel.font = Design.Fonts.small
        nameLabel.textColor = Design.Colors.textPrimary
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = Design.Colors.textSecondary.withAlphaComponent(0.8)
        nameLabel.layer.cornerRadius = 4
        nameLabel.layer.masksToBounds = true
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    private func updateCard() {
        guard let card = card else {
            imageView.image = UIImage(named: "card_back")
            nameLabel.isHidden = true
            return
        }
        
        imageView.image = UIImage(named: card.imageName) ?? UIImage(named: "card_back")
        nameLabel.text = "  \(card.name)  "
        nameLabel.isHidden = false
        imageView.transform = card.isReversed ? CGAffineTransform(rotationAngle: .pi) : .identity
    }
    
    private func updateFlipState() {
        if isFlipped {
            imageView.image = UIImage(named: "card_back")
            nameLabel.isHidden = true
        } else {
            updateCard()
        }
    }
    
    func flip(to card: TarotCard, completion: (() -> Void)? = nil) {
        self.card = card
        isFlipped = true
        
        UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromRight) {
            self.isFlipped = false
        } completion: { _ in
            completion?()
        }
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        onTap?()
    }
}
