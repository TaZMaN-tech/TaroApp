//
//  MainViewModel.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import Foundation
import Combine

// MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    var userName: String { get set }
    var userNamePublisher: Published<String>.Publisher { get }
    var isValidName: Bool { get }
    var spreadTypes: [SpreadType] { get }
    
    func selectSpread(_ type: SpreadType)
    func loadUserSettings()
    func saveUserName()
}

// MARK: - Implementation

final class MainViewModel: MainViewModelProtocol {
    
    @Published var userName: String = ""
    var userNamePublisher: Published<String>.Publisher { $userName }
    
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
        coordinator?.showPrediction(for: type, userName: userName.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func loadUserSettings() {
        let settings = storageService.getUserSettings()
        userName = settings.userName
    }
    
    func saveUserName() {
        var settings = storageService.getUserSettings()
        settings.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        storageService.saveUserSettings(settings)
    }
}
