//
//  PredictionViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 20.03.2025.
//

import UIKit

final class PredictionViewController: UIViewController {

    @IBOutlet var firstTaroImageView: UIImageView!
    @IBOutlet var secondTaroImageView: UIImageView!
    @IBOutlet var thirdTaroImageView: UIImageView!

    @IBOutlet var predictionTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!

    var name: String!
    var prediction: String!

    private let predictionManager = PredictionManager()
    private var isLoadingStarted = false

    private var loadingVC: LoadingViewController?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundGradient()
        addGradientBackground()
        addStarOverlay()
        animateElements()
        styleBackButton()
        
        predictionTextView.accessibilityLabel = NSLocalizedString("prediction_result_accessibility", comment: "")
        predictionTextView.adjustsFontForContentSizeCategory = true
        predictionTextView.font = UIFont.preferredFont(forTextStyle: .body)

        [firstTaroImageView, secondTaroImageView, thirdTaroImageView].forEach {
            $0?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            $0?.addGestureRecognizer(tap)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isLoadingStarted {
            isLoadingStarted = true
            showLoadingAndStartPrediction()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.sublayers?.first?.frame = backButton.bounds
    }

    // MARK: - Prediction Flow
    private func showLoadingAndStartPrediction() {
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        self.loadingVC = loadingVC

        present(loadingVC, animated: true) {
            self.startPredictionFlow()
        }
    }
    
    // MARK: - UI Setup
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.85, green: 0.9, blue: 0.8, alpha: 1).cgColor,  // мягкий зелёно-голубой
            UIColor(red: 1.0, green: 0.92, blue: 0.7, alpha: 1).cgColor,  // песочно-жёлтый
            UIColor(red: 0.95, green: 0.8, blue: 0.6, alpha: 1).cgColor   // тёплый терракотово-бежевый
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func addGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.85, green: 0.9, blue: 0.8, alpha: 1).cgColor,
            UIColor(red: 1.0, green: 0.92, blue: 0.7, alpha: 1).cgColor,
            UIColor(red: 0.95, green: 0.8, blue: 0.6, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func addStarOverlay() {
        let stars = UIImageView(image: UIImage(named: "stars_background"))
        stars.alpha = 0.12
        stars.contentMode = .scaleAspectFit
        stars.frame = view.bounds
        view.insertSubview(stars, at: 1)
    }

    private func animateElements() {
        let cardViews = [firstTaroImageView, secondTaroImageView, thirdTaroImageView]
        for view in cardViews {
            view?.alpha = 0
        }
        predictionTextView.alpha = 0

        for (index, view) in cardViews.enumerated() {
            UIView.animate(withDuration: 1.0, delay: Double(index) * 0.3, options: [.curveEaseOut], animations: {
                view?.alpha = 1
            }, completion: nil)
        }

        UIView.animate(withDuration: 1.0, delay: 0.9, options: [.curveEaseOut], animations: {
            self.predictionTextView.alpha = 1
        }, completion: nil)
    }

    private func startPredictionFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.predictionManager.drawCards()
            self.setupCards()

            //let prompt = self.predictionManager.generatePrompt(name: self.name ?? "", prediction: self.prediction ?? "")
            
            let cards = self.predictionManager.cards.map { $0.name }
            let lang: String
            if #available(iOS 16.0, *) {
                lang = Locale.current.language.languageCode?.identifier ?? "en"
            } else {
                lang = Locale.current.languageCode ?? "en"
            }
            self.predictionManager.callDeepseekAPI(cards: cards, name: self.name ?? "", subject: self.prediction ?? "", lang: lang) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let content):
                        print("Ответ от Deepseek: \(content)")
                        self.predictionTextView.setBoldText(from: content, baseFontSize: 20)
                        self.predictionTextView.textColor = .white
                        self.predictionTextView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                        self.predictionTextView.layer.cornerRadius = 12
                        self.predictionTextView.layer.masksToBounds = true
                        self.predictionTextView.textAlignment = .center
                    case .failure(let error):
                        print("Ошибка API: \(error.localizedDescription)")
                        self.predictionTextView.text = NSLocalizedString("prediction_error", comment: "")
                    }
                    
                    // Закрываем loading только после того, как UI обновился
                    self.dismissLoadingIfNeeded()
                }
            }
        }
    }

    private func setupCards() {
        let imageViews = [firstTaroImageView, secondTaroImageView, thirdTaroImageView]
        for (index, card) in predictionManager.cards.enumerated() {
            guard index < imageViews.count else { continue }
            let imageView = imageViews[index]
            let image = UIImage(named: "\(card.name).jpg")
            imageView?.image = image
            imageView?.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            
            image?.accessibilityIdentifier = "\(card.name).jpg"
            
            imageView?.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.6).cgColor
            imageView?.layer.borderWidth = 3
            imageView?.layer.cornerRadius = 12
            imageView?.clipsToBounds = true
            
            imageView?.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            imageView?.layer.borderWidth = 2
            
            if let container = imageView?.superview {
                container.layer.shadowOpacity = 0.9
                container.layer.shadowRadius = 20
                container.layer.shadowOffset = .zero
                container.layer.masksToBounds = false
            }
            
            imageView?.transform = card.rotation ? CGAffineTransform(rotationAngle: .pi) : .identity
            
            if card.rotation {
                let icon = UILabel()
                icon.text = "🌀"
                icon.font = UIFont.systemFont(ofSize: 16)
                icon.translatesAutoresizingMaskIntoConstraints = false
                imageView?.addSubview(icon)
                NSLayoutConstraint.activate([
                    icon.trailingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: -6),
                    icon.topAnchor.constraint(equalTo: imageView!.topAnchor, constant: 6)
                ])
            }
            
            let nameLabel = UILabel()
            nameLabel.text = card.name
            nameLabel.textColor = .white
            nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            nameLabel.textAlignment = .center
            nameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            nameLabel.layer.cornerRadius = 6
            nameLabel.layer.masksToBounds = true
            nameLabel.translatesAutoresizingMaskIntoConstraints = false

            if let container = imageView?.superview {
                container.addSubview(nameLabel)
                NSLayoutConstraint.activate([
                    nameLabel.topAnchor.constraint(equalTo: imageView!.bottomAnchor, constant: 4),
                    nameLabel.centerXAnchor.constraint(equalTo: imageView!.centerXAnchor),
                    nameLabel.widthAnchor.constraint(equalTo: imageView!.widthAnchor)
                ])
            }
        }
    }

    private func dismissLoadingIfNeeded() {
        if let loadingVC = self.loadingVC {
            loadingVC.dismiss(animated: true)
            self.loadingVC = nil
        }
    }

    private func styleBackButton() {
        backButton.setTitle(NSLocalizedString("new_prediction", comment: ""), for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.layer.cornerRadius = 16
        backButton.layer.masksToBounds = true

        backButton.accessibilityLabel = NSLocalizedString("new_prediction", comment: "")
        backButton.accessibilityHint = NSLocalizedString("new_prediction_hint", comment: "")
        backButton.titleLabel?.adjustsFontForContentSizeCategory = true
        backButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.9, green: 0.6, blue: 0.3, alpha: 1).cgColor, // насыщенный песочно-оранжевый
            UIColor(red: 0.4, green: 0.7, blue: 0.7, alpha: 1).cgColor  // приглушённый бирюзовый
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = backButton.bounds
        backButton.layoutIfNeeded()
        gradient.frame = backButton.bounds

        backButton.layer.insertSublayer(gradient, at: 0)
        gradient.cornerRadius = backButton.layer.cornerRadius

        backButton.layer.shadowColor = UIColor.purple.cgColor
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        backButton.layer.shadowRadius = 6
        backButton.layer.masksToBounds = false
        backButton.contentHorizontalAlignment = .center
    }

    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Card Interaction
    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let image = tappedImageView.image else { return }
        
        let cardName = (image.accessibilityIdentifier ?? "Карта Таро").replacingOccurrences(of: ".jpg", with: "")
        
        let fullscreenView = UIView(frame: view.bounds)
        fullscreenView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.frame = fullscreenView.bounds
        fullscreenView.addSubview(blur)
        
        let imageContainer = UIView()
        imageContainer.frame = tappedImageView.convert(tappedImageView.bounds, to: self.view)
        imageContainer.layer.cornerRadius = 20
        imageContainer.clipsToBounds = true
        fullscreenView.addSubview(imageContainer)

        let enlargedImageView = UIImageView(image: image)
        enlargedImageView.contentMode = .scaleAspectFit
        enlargedImageView.frame = imageContainer.bounds
        enlargedImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageContainer.addSubview(enlargedImageView)

        let nameLabel = UILabel()
        nameLabel.text = cardName
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        nameLabel.textAlignment = .center
        nameLabel.alpha = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        fullscreenView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: fullscreenView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 16)
        ])

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenView(_:)))
        fullscreenView.addGestureRecognizer(dismissTap)
        fullscreenView.isUserInteractionEnabled = true
        
        fullscreenView.isAccessibilityElement = true
        fullscreenView.accessibilityViewIsModal = true

        let accessibilityLabel = String(format: NSLocalizedString("fullscreen_card_accessibility", comment: ""), cardName)
        fullscreenView.accessibilityLabel = accessibilityLabel
        fullscreenView.accessibilityTraits = .image

        view.addSubview(fullscreenView)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: [], animations: {
            imageContainer.frame = CGRect(
                x: 20,
                y: self.view.bounds.height * 0.2,
                width: self.view.bounds.width - 40,
                height: self.view.bounds.height * 0.5
            )
            nameLabel.alpha = 1
        }, completion: nil)
    }

    @objc private func dismissFullscreenView(_ sender: UITapGestureRecognizer) {
        guard let fullscreenView = sender.view else { return }
        UIView.animate(withDuration: 0.3, animations: {
            fullscreenView.alpha = 0
        }) { _ in
            fullscreenView.removeFromSuperview()
        }
    }
}
