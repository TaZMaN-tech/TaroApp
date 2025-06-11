//
//  ViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 19.03.2025.
//

import YandexMobileAds
import UIKit

final class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var lovePredictionButton: UIButton!
    @IBOutlet var jobPredictionButton: UIButton!
    @IBOutlet var dayPredictionButton: UIButton!
    @IBOutlet var futurePredictionButton: UIButton!
    @IBOutlet var selfDiscoveryButton: UIButton!
    @IBOutlet var yesNoButton: UIButton!
    @IBOutlet var karmaButton: UIButton!
    
    private var predictionButtons: [UIButton] {
        return [
            lovePredictionButton,
            jobPredictionButton,
            dayPredictionButton,
            futurePredictionButton,
            selfDiscoveryButton,
            yesNoButton,
            karmaButton
        ]
    }
    
    private lazy var interstitialAdLoader: InterstitialAdLoader = {
        let loader = InterstitialAdLoader()
        loader.delegate = self
        return loader
    }()
    
    private var interstitialAd: InterstitialAd?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        addGradientBackground()
        addStarOverlay()
        nameTextField.delegate = self
        loadInterstitialAd()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateButtonGradients()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPredictionVC",
           let predictionVC = segue.destination as? PredictionViewController,
           let button = sender as? UIButton {
            predictionVC.name = nameTextField.text
            predictionVC.prediction = button.titleLabel?.text
        }
    }
    
    // MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(
                title: NSLocalizedString("empty_name_title", comment: "Введите имя"),
                message: NSLocalizedString("empty_name_message", comment: "Пожалуйста, введите имя перед тем как продолжить."),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok_button", comment: "ОК"), style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        performSegue(withIdentifier: "toPredictionVC", sender: sender)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Заголовок
        greetingLabel.text = NSLocalizedString("greeting_text", comment: "")
        greetingLabel.accessibilityLabel = NSLocalizedString("greeting_accessibility", comment: "")
        greetingLabel.accessibilityTraits = .header
        greetingLabel.adjustsFontForContentSizeCategory = true
        greetingLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        greetingLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        greetingLabel.textColor = UIColor(red: 72/255, green: 58/255, blue: 50/255, alpha: 1.0) // более контрастный тёплый коричневый
        greetingLabel.layer.shadowColor = UIColor(red: 255/255, green: 190/255, blue: 0, alpha: 0.5).cgColor
        greetingLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        greetingLabel.layer.shadowRadius = 8
        greetingLabel.layer.shadowOpacity = 1.0
        greetingLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        greetingLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        greetingLabel.layer.borderWidth = 1.0
        greetingLabel.layer.cornerRadius = 20
        greetingLabel.layer.masksToBounds = true
        
        // Текстовое поле
        nameTextField.placeholder = NSLocalizedString("placeholder_name", comment: "")
        nameTextField.accessibilityLabel = NSLocalizedString("name_field_accessibility", comment: "")
        nameTextField.accessibilityHint = NSLocalizedString("name_field_hint", comment: "")
        nameTextField.adjustsFontForContentSizeCategory = true
        nameTextField.font = UIFont.preferredFont(forTextStyle: .body)
        nameTextField.layer.cornerRadius = 14
        nameTextField.layer.masksToBounds = true
        
        // Кнопки с эмодзи
        for (button, title, colors) in buttonConfigurations() {
            styleButton(button, title: title, colors: colors)
        }
        
        animateElements()
    }
    
    private func buttonConfigurations() -> [(UIButton, String, [CGColor])] {
        return [
            (lovePredictionButton, NSLocalizedString("love_button", comment: ""), [
                UIColor(red: 230/255, green: 110/255, blue: 120/255, alpha: 1.0).cgColor,
                UIColor(red: 240/255, green: 160/255, blue: 80/255, alpha: 1.0).cgColor
            ]),
            (jobPredictionButton, NSLocalizedString("job_button", comment: ""), [
                UIColor(red: 60/255, green: 100/255, blue: 140/255, alpha: 1.0).cgColor,
                UIColor(red: 185/255, green: 140/255, blue: 70/255, alpha: 1.0).cgColor
            ]),
            (dayPredictionButton, NSLocalizedString("day_button", comment: ""), [
                UIColor(red: 255/255, green: 200/255, blue: 40/255, alpha: 1.0).cgColor,
                UIColor(red: 245/255, green: 160/255, blue: 60/255, alpha: 1.0).cgColor
            ]),
            (futurePredictionButton, NSLocalizedString("future_button", comment: ""), [
                UIColor(red: 120/255, green: 210/255, blue: 235/255, alpha: 1.0).cgColor,
                UIColor(red: 135/255, green: 180/255, blue: 210/255, alpha: 1.0).cgColor
            ]),
            (selfDiscoveryButton, NSLocalizedString("self_button", comment: ""), [
                UIColor(red: 80/255, green: 150/255, blue: 60/255, alpha: 1.0).cgColor,
                UIColor(red: 145/255, green: 210/255, blue: 145/255, alpha: 1.0).cgColor
            ]),
            (yesNoButton, NSLocalizedString("health_button", comment: ""), [
                UIColor(red: 200/255, green: 130/255, blue: 30/255, alpha: 1.0).cgColor,
                UIColor(red: 255/255, green: 190/255, blue: 110/255, alpha: 1.0).cgColor
            ]),
            (karmaButton, NSLocalizedString("karma_button", comment: ""), [
                UIColor(red: 70/255, green: 200/255, blue: 215/255, alpha: 1.0).cgColor,
                UIColor(red: 100/255, green: 180/255, blue: 210/255, alpha: 1.0).cgColor
            ])
        ]
    }
    
    // MARK: - Helpers
    
    private func styleButton(_ button: UIButton, title: String, colors: [CGColor]) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = title
            config.baseForegroundColor = .white
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
                return outgoing
            }
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            button.layer.cornerRadius = 14
            button.layer.masksToBounds = true
            button.titleEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        
        let gradientLayer = makeGradientLayer(frame: button.bounds, colors: colors)
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func addGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        gradient.colors = [
            UIColor(red: 125/255, green: 207/255, blue: 235/255, alpha: 1.0).cgColor,
            UIColor(red: 255/255, green: 184/255, blue: 108/255, alpha: 1.0).cgColor
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
    
    private func updateButtonGradients() {
        for button in predictionButtons {
            if let gradient = button.layer.sublayers?.first(where: { $0.name == "buttonGradient" }) as? CAGradientLayer {
                gradient.frame = button.bounds
            }
        }
    }
    
    private func animateElements() {
        for button in predictionButtons {
            button.alpha = 0
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        for (index, button) in predictionButtons.enumerated() {
            UIView.animate(
                withDuration: 1.0,
                delay: 0.6 + Double(index) * 0.2,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    button.alpha = 1
                    button.transform = .identity
                },
                completion: nil
            )
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func makeGradientLayer(frame: CGRect, colors: [CGColor], cornerRadius: CGFloat = 14) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = cornerRadius
        gradient.name = "buttonGradient"
        return gradient
    }
    
    private func loadInterstitialAd() {
        let configuration = AdRequestConfiguration(adUnitID: "R-M-15108836-1") // замените на ваш adUnitID
        interstitialAdLoader.loadAd(with: configuration)
    }
}

extension MainViewController: InterstitialAdLoaderDelegate {
    func interstitialAdLoader(_ adLoader: InterstitialAdLoader, didLoad interstitialAd: InterstitialAd) {
        self.interstitialAd = interstitialAd
        self.interstitialAd?.delegate = self
        self.interstitialAd?.show(from: self)
    }
    
    func interstitialAdLoader(_ adLoader: InterstitialAdLoader, didFailToLoadWithError error: AdRequestError) {
        print("Не удалось загрузить рекламу)")
    }
}


extension MainViewController: InterstitialAdDelegate {
    func interstitialAdDidDismiss(_ interstitialAd: InterstitialAd) {
        print("Реклама была закрыта пользователем.")
    }
    
    func interstitialAd(_ interstitialAd: InterstitialAd, didFailToShowWithError error: Error) {
        print("Ошибка показа рекламы: \(error.localizedDescription)")
    }
}
