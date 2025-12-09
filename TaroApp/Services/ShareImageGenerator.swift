//
//  ShareImageGenerator.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import UIKit

final class ShareImageGenerator {
    
    // MARK: - Public Methods
    
    static func generateImage(for prediction: Prediction) -> UIImage? {
        let size = CGSize(width: 400, height: 650)
        
        let containerView = createContainerView(size: size)
        addGradientBackground(to: containerView, prediction: prediction)
        addContent(to: containerView, prediction: prediction)
        
        return renderImage(from: containerView)
    }
    
    // MARK: - Private Methods
    
    private static func createContainerView(size: CGSize) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        view.backgroundColor = .white
        return view
    }
    
    private static func addGradientBackground(to view: UIView, prediction: Prediction) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            prediction.spreadType.gradientColors.start.cgColor,
            prediction.spreadType.gradientColors.end.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private static func addContent(to view: UIView, prediction: Prediction) {
        // Заголовок
        let iconLabel = createIconLabel(icon: prediction.spreadType.icon)
        view.addSubview(iconLabel)
        iconLabel.frame = CGRect(x: 0, y: 40, width: view.bounds.width, height: 60)
        
        // Тип расклада
        let titleLabel = createTitleLabel(text: "🔮 \(prediction.spreadType.title)")
        view.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 20, y: 110, width: view.bounds.width - 40, height: 40)
        
        // Имя и дата
        let subtitleLabel = createSubtitleLabel(prediction: prediction)
        view.addSubview(subtitleLabel)
        subtitleLabel.frame = CGRect(x: 20, y: 155, width: view.bounds.width - 40, height: 45)
        
        // Карты
        let cardsContainer = createCardsContainer(prediction: prediction)
        view.addSubview(cardsContainer)
        cardsContainer.frame = CGRect(x: 40, y: 220, width: view.bounds.width - 80, height: 170)
        
        // Названия карт
        let cardNamesLabel = createCardNamesLabel(prediction: prediction)
        view.addSubview(cardNamesLabel)
        cardNamesLabel.frame = CGRect(x: 20, y: 405, width: view.bounds.width - 40, height: 60)
        
        // Сепаратор
        let separator = createSeparator()
        view.addSubview(separator)
        separator.frame = CGRect(x: 30, y: 475, width: view.bounds.width - 60, height: 1)
        
        // Текст предсказания (краткий)
        let textLabel = createTextLabel(text: prediction.text)
        view.addSubview(textLabel)
        textLabel.frame = CGRect(x: 30, y: 490, width: view.bounds.width - 60, height: 100)
        
        // Логотип
        let logoLabel = createLogoLabel()
        view.addSubview(logoLabel)
        logoLabel.frame = CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 30)
    }
    
    // MARK: - UI Components
    
    private static func createIconLabel(icon: String) -> UILabel {
        let label = UILabel()
        label.text = icon
        label.font = UIFont.systemFont(ofSize: 56)
        label.textAlignment = .center
        return label
    }
    
    private static func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
    
    private static func createSubtitleLabel(prediction: Prediction) -> UILabel {
        let label = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let format = L10n.tr("history_cell_title_format")
        let subtitle = String(format: format, "", prediction.userName)
        label.text = "\(subtitle)\n\(dateFormatter.string(from: prediction.createdAt))"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.95)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }
    
    private static func createCardsContainer(prediction: Prediction) -> UIView {
        let container = UIView()
        
        let cardWidth: CGFloat = 90
        let cardHeight: CGFloat = 140
        let spacing: CGFloat = 15
        let totalWidth = CGFloat(prediction.cards.count) * cardWidth + CGFloat(prediction.cards.count - 1) * spacing
        let startX = (320 - totalWidth) / 2
        
        for (index, card) in prediction.cards.enumerated() {
            let cardView = createCardView(card: card)
            cardView.frame = CGRect(
                x: startX + CGFloat(index) * (cardWidth + spacing),
                y: 0,
                width: cardWidth,
                height: cardHeight
            )
            container.addSubview(cardView)
        }
        
        return container
    }
    
    private static func createCardView(card: TarotCard) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.3
        view.layer.masksToBounds = false
        
        // Картинка карты
        if let cardImage = UIImage(named: card.imageName) {
            let imageView = UIImageView(frame: view.bounds)
            imageView.image = cardImage
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            // Если карта перевёрнута
            if card.isReversed {
                imageView.transform = CGAffineTransform(rotationAngle: .pi)
            }
            
            view.addSubview(imageView)
        }
        
        return view
    }
    
    private static func createCardNamesLabel(prediction: Prediction) -> UILabel {
        let label = UILabel()
        let cardNames = prediction.cards.map { card in
            card.isReversed ? "\(card.localizedName) ⟲" : card.localizedName
        }.joined(separator: " • ")
        label.text = "🃏 \(cardNames)"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }
    
    private static func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        return view
    }
    
    private static func createTextLabel(text: String) -> UILabel {
        let label = UILabel()
        let shortText = String(text.prefix(180))
        label.text = shortText + (text.count > 180 ? "..." : "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.95)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private static func createLogoLabel() -> UILabel {
        let label = UILabel()
        label.text = "TaroApp ✨"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.85)
        label.textAlignment = .center
        return label
    }
    
    private static func renderImage(from view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
    }
}
