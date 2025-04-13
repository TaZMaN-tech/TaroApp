//
//  ViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 19.03.2025.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var lovePredictionButton: UIButton!
    @IBOutlet var jobPredictionButton: UIButton!
    @IBOutlet var dayPredictionButton: UIButton!
    @IBOutlet var futurePredictionButton: UIButton!
    @IBOutlet var selfDiscoveryButton: UIButton!
    @IBOutlet var yesNoButton: UIButton!
    @IBOutlet var karmaButton: UIButton!

    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            greetingLabel.numberOfLines = 0
            greetingLabel.textAlignment = .center
            addGradientBackground()
            addStarOverlay()
            nameTextField.delegate = self
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

        @IBAction func buttonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toPredictionVC", sender: sender)
        }

        // MARK: - Setup

        func setupUI() {
            // Заголовок
            greetingLabel.text = "✨ Судьба шепчет твоё имя… Напиши его, и карты откроют истину"
            greetingLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
            greetingLabel.textColor = UIColor.white
            greetingLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            greetingLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            greetingLabel.layer.borderWidth = 1.0
            greetingLabel.layer.cornerRadius = 20
            greetingLabel.layer.masksToBounds = true

            // Текстовое поле
            nameTextField.placeholder = "Введите имя"
            nameTextField.layer.cornerRadius = 14
            nameTextField.layer.masksToBounds = true

            // Кнопки с эмодзи
            styleButton(lovePredictionButton, title: "❤️ Расклад на любовь", colors: [UIColor.systemPink.cgColor, UIColor.systemRed.cgColor])
            styleButton(jobPredictionButton, title: "💼 Расклад на работу", colors: [UIColor.systemIndigo.cgColor, UIColor.systemBlue.cgColor])
            styleButton(dayPredictionButton, title: "🌞 Расклад на день", colors: [UIColor.systemTeal.cgColor, UIColor.systemCyan.cgColor])
            styleButton(futurePredictionButton, title: "🔮 Расклад на будущее", colors: [UIColor.systemPurple.cgColor, UIColor.systemIndigo.cgColor])

        
            styleButton(selfDiscoveryButton, title: "🧘 Расклад на гармонию", colors: [UIColor.systemGreen.cgColor, UIColor.systemMint.cgColor])


            styleButton(yesNoButton, title: "🩺 Расклад на здоровье", colors: [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor])

            styleButton(karmaButton, title: "🏖️ Расклад на отпуск", colors: [UIColor.systemIndigo.cgColor, UIColor.systemPurple.cgColor])



            animateElements()
        }

        func styleButton(_ button: UIButton, title: String, colors: [CGColor]) {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 14
            button.layer.masksToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

            // Градиент
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = button.bounds
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 14

            button.layer.insertSublayer(gradientLayer, at: 0)
        }

        // Градиентный фон экрана
    func addGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        gradient.colors = [
            UIColor(red: 1.0, green: 0.85, blue: 0.8, alpha: 1.0).cgColor,   // светло-персиковый
            UIColor(red: 1.0, green: 0.7, blue: 0.75, alpha: 1.0).cgColor    // нежно-розовый
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
    }

        // Звёздный фон (в виде изображения)
        func addStarOverlay() {
            let stars = UIImageView(image: UIImage(named: "stars_background"))
            stars.alpha = 0.12
            stars.contentMode = .scaleAspectFit
            stars.frame = view.bounds
            view.insertSubview(stars, at: 1)
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Обновляем градиенты кнопок, когда стали известны размеры
            updateButtonGradients()
        }

        func updateButtonGradients() {
            for button in [lovePredictionButton, jobPredictionButton, dayPredictionButton, futurePredictionButton, selfDiscoveryButton, yesNoButton, karmaButton] {
                if let gradient = button?.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
                    gradient.frame = button?.bounds ?? .zero
                }
            }
        }

    func animateElements() {
        // Начальное состояние
        greetingLabel.alpha = 0
        nameTextField.alpha = 0
        lovePredictionButton.alpha = 0
        jobPredictionButton.alpha = 0
        dayPredictionButton.alpha = 0
        futurePredictionButton.alpha = 0
        selfDiscoveryButton.alpha = 0
        yesNoButton.alpha = 0
        karmaButton.alpha = 0

        // Анимация появления с небольшими задержками
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveEaseOut], animations: {
            self.greetingLabel.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 0.4, options: [.curveEaseOut], animations: {
            self.nameTextField.alpha = 1
        }, completion: nil)

        self.view.backgroundColor = .clear
        UIView.animate(withDuration: 1.0, delay: 0.6, options: [.curveEaseOut], animations: {
            self.lovePredictionButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 0.8, options: [.curveEaseOut], animations: {
            self.jobPredictionButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 1.0, options: [.curveEaseOut], animations: {
            self.dayPredictionButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 1.2, options: [.curveEaseOut], animations: {
            self.futurePredictionButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 1.4, options: [.curveEaseOut], animations: {
            self.selfDiscoveryButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 1.6, options: [.curveEaseOut], animations: {
            self.yesNoButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 1.0, delay: 1.8, options: [.curveEaseOut], animations: {
            self.karmaButton.alpha = 1
        }, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
