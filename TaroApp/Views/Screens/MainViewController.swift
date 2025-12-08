//
//  MainViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backgroundView: GradientView = {
        let view = GradientView()
        view.colors = [Design.Colors.gradientStart, Design.Colors.gradientEnd]
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
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.text = "🔮"
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Таро"
        label.font = Design.Fonts.largeTitle
        label.textColor = Design.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Напиши своё имя, и карты\nоткроют истину ✨"
        label.font = Design.Fonts.body
        label.textColor = Design.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите имя"
        field.font = Design.Fonts.body
        field.textAlignment = .center
        field.backgroundColor = .white
        field.layer.cornerRadius = Design.CornerRadius.medium
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var buttonsGrid: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        button.tintColor = Design.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = Design.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private let viewModel: MainViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: MainViewModelProtocol) {
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
        setupButtonsGrid()
        setupBindings()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(historyButton)
        contentView.addSubview(settingsButton)
        contentView.addSubview(logoLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(buttonsGrid)
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
            
            historyButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Design.Spacing.m),
            historyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Design.Spacing.l),
            historyButton.widthAnchor.constraint(equalToConstant: 44),
            historyButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Design.Spacing.m),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Design.Spacing.l),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Design.Spacing.xxl),
            logoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: Design.Spacing.m),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Design.Spacing.s),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Design.Spacing.xxl),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Design.Spacing.xxl),
            
            nameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Design.Spacing.xl),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Design.Spacing.l),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Design.Spacing.l),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            buttonsGrid.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Design.Spacing.xl),
            buttonsGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Design.Spacing.l),
            buttonsGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Design.Spacing.l),
            buttonsGrid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Design.Spacing.xxl)
        ])
    }
    
    private func setupButtonsGrid() {
        let spacing: CGFloat = Design.Spacing.m
        let columns = 2
        let rows = 4
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = spacing
        verticalStack.distribution = .fillEqually
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsGrid.addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: buttonsGrid.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: buttonsGrid.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: buttonsGrid.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: buttonsGrid.bottomAnchor),
            verticalStack.heightAnchor.constraint(equalToConstant: CGFloat(rows) * 100 + CGFloat(rows - 1) * spacing)
        ])
        
        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = spacing
            rowStack.distribution = .fillEqually
            
            for col in 0..<columns {
                let index = row * columns + col
                
                if index < viewModel.spreadTypes.count {
                    let spreadType = viewModel.spreadTypes[index]
                    let button = GradientButton()
                    button.configure(icon: spreadType.icon, title: spreadType.title, colors: spreadType.gradientColors)
                    button.tag = index
                    button.addTarget(self, action: #selector(spreadButtonTapped(_:)), for: .touchUpInside)
                    rowStack.addArrangedSubview(button)
                } else {
                    let placeholder = UIView()
                    rowStack.addArrangedSubview(placeholder)
                }
            }
            
            verticalStack.addArrangedSubview(rowStack)
        }
    }
    
    private func setupBindings() {
        nameTextField.text = viewModel.userName
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func nameTextFieldChanged() {
        viewModel.userName = nameTextField.text ?? ""
    }
    
    @objc private func spreadButtonTapped(_ sender: UIButton) {
        guard viewModel.isValidName else {
            showNameRequiredAlert()
            return
        }
        
        let spreadType = viewModel.spreadTypes[sender.tag]
        viewModel.selectSpread(spreadType)
    }
    
    @objc private func historyTapped() {
        (viewModel as? MainViewModel)?.coordinator?.showHistory()
    }
    
    @objc private func settingsTapped() {
        (viewModel as? MainViewModel)?.coordinator?.showSettings()
    }
    
    private func showNameRequiredAlert() {
        let alert = UIAlertController(title: "Введите имя", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.nameTextField.becomeFirstResponder()
        })
        present(alert, animated: true)
        
        // Shake animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        nameTextField.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
