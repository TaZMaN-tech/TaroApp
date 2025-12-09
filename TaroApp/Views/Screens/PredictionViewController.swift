//
//  PredictionViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit
import Combine

final class PredictionViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backgroundView: GradientView = {
        let view = GradientView()
        view.colors = [
            UIColor(red: 0.85, green: 0.9, blue: 0.8, alpha: 1),
            UIColor(red: 1.0, green: 0.92, blue: 0.7, alpha: 1)
        ]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Design.Colors.textPrimary
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
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
        textView.textColor = .white
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        textView.layer.cornerRadius = Design.CornerRadius.medium
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Design.Spacing.m
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setTitle(" Избранное", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = Design.CornerRadius.medium
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.setTitle(" Поделиться", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = Design.CornerRadius.medium
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newReadingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Новый расклад", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Design.Fonts.caption
        button.backgroundColor = Design.Colors.gradientStart
        button.layer.cornerRadius = Design.CornerRadius.medium
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newReadingTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var cardViews: [TarotCardView] = []
    
    // MARK: - Properties
    
    private let viewModel: PredictionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: PredictionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if case .idle = viewModel.state {
            // ✅ Запускаем анимации ДО начала загрузки
            loadingView.startAnimations()
            
            // Небольшая задержка чтобы анимации точно начались
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.viewModel.loadPrediction()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(closeButton)
        contentView.addSubview(cardsStack)
        contentView.addSubview(predictionTextView)
        contentView.addSubview(buttonsStack)
        contentView.addSubview(newReadingButton)
        
        buttonsStack.addArrangedSubview(favoriteButton)
        buttonsStack.addArrangedSubview(shareButton)
        
        view.addSubview(loadingView)
        
        for index in 0..<3 {
            let cardView = TarotCardView()
            cardView.isFlipped = true
            
            cardView.onTap = { [weak self] in
                self?.showCardFullscreen(at: index)
            }
            
            cardsStack.addArrangedSubview(cardView)
            cardViews.append(cardView)
        }
        
        loadingView.isHidden = false
        scrollView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            
            cardsStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            cardsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardsStack.heightAnchor.constraint(equalToConstant: 160),
            
            predictionTextView.topAnchor.constraint(equalTo: cardsStack.bottomAnchor, constant: 24),
            predictionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            predictionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            buttonsStack.topAnchor.constraint(equalTo: predictionTextView.bottomAnchor, constant: 16),
            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 44),
            
            newReadingButton.topAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 16),
            newReadingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newReadingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newReadingButton.heightAnchor.constraint(equalToConstant: 50),
            newReadingButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: LoadingState<Prediction>) {
        switch state {
        case .idle:
            break
            
        case .loading:
            loadingView.isHidden = false
            scrollView.isHidden = true
            
        case .loaded(let prediction):
            loadingView.stopAnimations()
            loadingView.isHidden = true
            scrollView.isHidden = false
            displayPrediction(prediction)
            animateCards()
            
        case .error(let error):
            loadingView.stopAnimations()
            loadingView.isHidden = true
            scrollView.isHidden = false
            showError(error)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.loadPrediction()
        })
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel) { [weak self] _ in
            self?.viewModel.dismiss()
        })
        present(alert, animated: true)
    }
    
    private func displayPrediction(_ prediction: Prediction) {
        for (index, card) in prediction.cards.enumerated() where index < cardViews.count {
            cardViews[index].card = card
        }
        predictionTextView.attributedText = formatPredictionText(prediction.text)
        updateFavoriteButton(isFavorite: prediction.isFavorite)
    }
    
    private func formatPredictionText(_ text: String) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 17)
        let boldFont = UIFont.boldSystemFont(ofSize: 17)
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: baseFont,
            .foregroundColor: UIColor.white
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
    
    private func animateCards() {
        for (index, cardView) in cardViews.enumerated() {
            guard index < viewModel.cards.count else { continue }
            let card = viewModel.cards[index]
            cardView.isFlipped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                cardView.flip(to: card)
            }
        }
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemPink : .white
    }
    
    // MARK: - Fullscreen Card

    private func showCardFullscreen(at index: Int) {
        guard index < viewModel.cards.count else { return }
        
        let card = viewModel.cards[index]
        let fullscreenVC = FullscreenCardViewController(card: card)
        present(fullscreenVC, animated: true)
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.dismiss()
    }
    
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    @objc private func shareTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Показываем action sheet с выбором
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Поделиться текстом
        alert.addAction(UIAlertAction(title: "Поделиться текстом", style: .default) { [weak self] _ in
            guard let text = self?.viewModel.sharePrediction() else { return }
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        })
        
        // Поделиться картинкой
        alert.addAction(UIAlertAction(title: "Поделиться картинкой 📸", style: .default) { [weak self] _ in
            self?.shareImage()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func shareImage() {
        guard case .loaded(let prediction) = viewModel.state,
              let image = ShareImageGenerator.generateImage(for: prediction) else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func newReadingTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.dismiss()
    }
}
