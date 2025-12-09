//
//  MainViewModel.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import Foundation
import Combine

// MARK: - UI State

enum MainScreenState {
    case onboarding
    case personalized
}

// MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    var userName: String { get set }
    var userNamePublisher: Published<String>.Publisher { get }
    var screenState: MainScreenState { get }
    var screenStatePublisher: Published<MainScreenState>.Publisher { get }
    var isValidName: Bool { get }
    var spreadTypes: [SpreadType] { get }
    
    func selectSpread(_ type: SpreadType)
    func loadUserSettings()
    func saveUserName()
    func startEditingName()
    func completeNameEntry()
    func didTapHistory()
    func didTapSettings()
}

// MARK: - Implementation

final class MainViewModel: MainViewModelProtocol {
    
    @Published var userName: String = ""
    @Published private(set) var screenState: MainScreenState = .onboarding
    
    var userNamePublisher: Published<String>.Publisher { $userName }
    var screenStatePublisher: Published<MainScreenState>.Publisher { $screenState }
    
    var isValidName: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let spreadTypes: [SpreadType] = SpreadType.allCases
    
    private let storageService: StorageServiceProtocol
    weak var coordinator: MainCoordinatorProtocol?
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        loadUserSettings()
    }
    
    
    func selectSpread(_ type: SpreadType) {
        guard isValidName else { return }
        saveUserName()
        
        if screenState == .onboarding {
            screenState = .personalized
        }
        
        coordinator?.showPrediction(for: type, userName: userName.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func loadUserSettings() {
        let settings = storageService.getUserSettings()
        userName = settings.userName
        
        // ← Определяем состояние экрана
        screenState = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? .onboarding
        : .personalized
    }
    
    func startEditingName() {
        screenState = .onboarding
    }
    
    func completeNameEntry() {
        screenState = .personalized
    }
    
    func saveUserName() {
        var settings = storageService.getUserSettings()
        settings.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        storageService.saveUserSettings(settings)
    }
    
    func didTapHistory() {
        coordinator?.showHistory()
    }
    
    func didTapSettings() {
        coordinator?.showSettings()
    }
}
