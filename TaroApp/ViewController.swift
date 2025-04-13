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
            nameTextField.placeholder = "Введите имя"
            nameTextField.layer.cornerRadius = 14
            nameTextField.layer.masksToBounds = true

            // Кнопки с эмодзи
            styleButton(lovePredictionButton, title: "❤️ Расклад на любовь", colors: [
                UIColor(red: 230/255, green: 110/255, blue: 120/255, alpha: 1.0).cgColor,
                UIColor(red: 240/255, green: 160/255, blue: 80/255, alpha: 1.0).cgColor
            ])
            
            styleButton(jobPredictionButton, title: "💼 Расклад на работу", colors: [
                UIColor(red: 60/255, green: 100/255, blue: 140/255, alpha: 1.0).cgColor,
                UIColor(red: 185/255, green: 140/255, blue: 70/255, alpha: 1.0).cgColor
            ])

            styleButton(dayPredictionButton, title: "🌞 Расклад на день", colors: [
                UIColor(red: 255/255, green: 200/255, blue: 40/255, alpha: 1.0).cgColor,
                UIColor(red: 245/255, green: 160/255, blue: 60/255, alpha: 1.0).cgColor
            ])

            styleButton(futurePredictionButton, title: "🔮 Расклад на будущее", colors: [
                UIColor(red: 120/255, green: 210/255, blue: 235/255, alpha: 1.0).cgColor,
                UIColor(red: 135/255, green: 180/255, blue: 210/255, alpha: 1.0).cgColor
            ])
        
            styleButton(selfDiscoveryButton, title: "🧘 Расклад на гармонию", colors: [
                UIColor(red: 80/255, green: 150/255, blue: 60/255, alpha: 1.0).cgColor,
                UIColor(red: 145/255, green: 210/255, blue: 145/255, alpha: 1.0).cgColor
            ])

            styleButton(yesNoButton, title: "🩺 Расклад на здоровье", colors: [
                UIColor(red: 200/255, green: 130/255, blue: 30/255, alpha: 1.0).cgColor,
                UIColor(red: 255/255, green: 190/255, blue: 110/255, alpha: 1.0).cgColor
            ])

            styleButton(karmaButton, title: "🏖️ Расклад на отпуск", colors: [
                UIColor(red: 70/255, green: 200/255, blue: 215/255, alpha: 1.0).cgColor,
                UIColor(red: 100/255, green: 180/255, blue: 210/255, alpha: 1.0).cgColor
            ])

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
            UIColor(red: 125/255, green: 207/255, blue: 235/255, alpha: 1.0).cgColor,  // Более яркий голубой
            UIColor(red: 255/255, green: 184/255, blue: 108/255, alpha: 1.0).cgColor   // Более насыщенный персиковый
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
