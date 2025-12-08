//
//  PredictionDetailViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class PredictionDetailViewController: UIViewController {
    
    private let prediction: Prediction
    private let storageService: StorageServiceProtocol
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = prediction.spreadType.gradientColors.start.withAlphaComponent(0.2)
        view.layer.cornerRadius = Design.CornerRadius.large
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.text = prediction.spreadType.icon
        label.font = UIFont.systemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = prediction.spreadType.title
        label.font = Design.Fonts.title
        label.textColor = Design.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        label.text = "для \(prediction.userName) • \(formatter.string(from: prediction.createdAt))"
        label.font = Design.Fonts.small
        label.textColor = Design.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Design.Spacing.m
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var predictionTextView: UITextView = {
        let textView = UITextView()
        textView.font = Design.Fonts.body
        textView.textColor = Design.Colors.textPrimary
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    init(prediction: Prediction, storageService: StorageServiceProtocol = StorageService.shared) {
        self.prediction = prediction
        self.storageService = storageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayPrediction()
    }
    
    private func setupUI() {
        title = "Расклад"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: prediction.isFavorite ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteToggled)
        )
        navigationItem.rightBarButtonItem?.tintColor = prediction.isFavorite ? .systemPink : Design.Colors.textPrimary
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(iconLabel)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        contentView.addSubview(cardsStack)
        contentView.addSubview(predictionTextView)
        
        for card in prediction.cards {
            let cardView = TarotCardView()
            cardView.card = card
            cardsStack.addArrangedSubview(cardView)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            cardsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            cardsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardsStack.heightAnchor.constraint(equalToConstant: 140),
            
            predictionTextView.topAnchor.constraint(equalTo: cardsStack.bottomAnchor, constant: 24),
            predictionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            predictionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            predictionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func displayPrediction() {
        predictionTextView.attributedText = formatText(prediction.text)
    }
    
    private func formatText(_ text: String) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 17)
        let boldFont = UIFont.boldSystemFont(ofSize: 17)
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: baseFont,
            .foregroundColor: Design.Colors.textPrimary
        ])
        
        let pattern = "\\*\\*(.*?)\\*\\*"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches.reversed() {
                let boldRange = match.range(at: 1)
                let fullRange = match.range(at: 0)
                let boldText = (text as NSString).substring(with: boldRange)
                attributedString.replaceCharacters(in: fullRange, with: boldText)
                attributedString.addAttribute(.font, value: boldFont, range: NSRange(location: fullRange.location, length: boldText.count))
            }
        }
        return attributedString
    }
    
    @objc private func favoriteToggled() {
        storageService.toggleFavorite(id: prediction.id)
        
        let newIsFavorite = !prediction.isFavorite
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: newIsFavorite ? "heart.fill" : "heart")
        navigationItem.rightBarButtonItem?.tintColor = newIsFavorite ? .systemPink : Design.Colors.textPrimary
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
