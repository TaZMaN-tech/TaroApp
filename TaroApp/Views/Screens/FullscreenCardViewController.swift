//
//  FullscreenCardViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import UIKit

final class FullscreenCardViewController: UIViewController {
    
    // MARK: - Properties
    
    private let card: TarotCard
    private var hasAppliedRotation = false
    
    // MARK: - UI Elements
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 3.0
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Fonts.title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(card: TarotCard) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        displayCard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Плавное появление
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.cardImageView.alpha = 1
        }
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(cardImageView)
        view.addSubview(cardNameLabel)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            cardNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cardNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardNameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: cardNameLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            cardImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            cardImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            cardImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupGestures() {
        // Tap для закрытия
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Swipe down для закрытия
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeTapped))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        
        // Double tap для zoom
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Делаем так чтобы single tap не срабатывал если был double tap
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    private func displayCard() {
        cardNameLabel.text = card.displayName
        
        if let image = UIImage(named: card.imageName) {
            cardImageView.image = image
            // ❌ НЕ применяем transform здесь
        } else {
            // Fallback
            cardImageView.image = UIImage(named: "card_back")
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        // Закрываем только если не в zoom режиме
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            closeTapped()
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // Если зумнуто - возвращаем обратно
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // Если не зумнуто - зумим в точку тапа
            let location = gesture.location(in: cardImageView)
            let rect = CGRect(
                x: location.x - 50,
                y: location.y - 50,
                width: 100,
                height: 100
            )
            scrollView.zoom(to: rect, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension FullscreenCardViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        cardImageView
    }
}
