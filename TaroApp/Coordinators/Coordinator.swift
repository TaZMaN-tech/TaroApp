//
//  Coordinator.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

// MARK: - Protocol

protocol MainCoordinatorProtocol: AnyObject {
    func showPrediction(for type: SpreadType, userName: String)
    func dismissPrediction()
    func showHistory()
    func showSettings()
    func showOnboarding()
    func showPredictionDetail(_ prediction: Prediction)
}

// MARK: - Implementation

final class MainCoordinator: MainCoordinatorProtocol {
    
    var navigationController: UINavigationController
    
    private let storageService: StorageServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(
        navigationController: UINavigationController,
        storageService: StorageServiceProtocol = StorageService.shared,
        networkService: NetworkServiceProtocol = NetworkService.shared
    ) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.networkService = networkService
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.tintColor = Design.Colors.textPrimary
    }
    
    // MARK: - Start
    
    func start() {
        // Сначала ВСЕГДА показываем главный экран
        showMain()
        
        // Потом проверяем нужен ли онбординг
        let settings = storageService.getUserSettings()
        if !settings.hasSeenOnboarding {
            showOnboarding()
        }
    }
    
    private func showMain() {
        let viewModel = MainViewModel(storageService: storageService)
        viewModel.coordinator = self
        
        let viewController = MainViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    // MARK: - Navigation
    
    func showPrediction(for type: SpreadType, userName: String) {
        let viewModel = PredictionViewModel(
            spreadType: type,
            userName: userName,
            networkService: networkService,
            storageService: storageService
        )
        viewModel.coordinator = self
        
        let viewController = PredictionViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
    
    func dismissPrediction() {
        navigationController.dismiss(animated: true)
    }
    
    func showHistory() {
        let viewModel = HistoryViewModel(storageService: storageService)
        viewModel.coordinator = self
        
        let viewController = HistoryViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSettings() {
        let viewController = SettingsViewController(storageService: storageService)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showOnboarding() {
        let viewController = OnboardingViewController { [weak self] in
            guard let self = self else { return }
            
            // Сохраняем что онбординг пройден
            var settings = self.storageService.getUserSettings()
            settings.hasSeenOnboarding = true
            self.storageService.saveUserSettings(settings)
        }
        viewController.modalPresentationStyle = .fullScreen
        
        // Небольшая задержка чтобы navigation controller успел настроиться
        DispatchQueue.main.async {
            self.navigationController.present(viewController, animated: false)
        }
    }
    
    func showPredictionDetail(_ prediction: Prediction) {
        let viewController = PredictionDetailViewController(prediction: prediction, storageService: storageService)
        navigationController.pushViewController(viewController, animated: true)
    }
}
