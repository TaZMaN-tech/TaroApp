//
//  HistoryViewModel.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import Foundation
import Combine

// MARK: - Tab

enum HistoryTab: Int, CaseIterable {
    case all = 0
    case favorites = 1
    
    var title: String {
        switch self {
        case .all: return "История"
        case .favorites: return "Избранное"
        }
    }
}

// MARK: - Protocol

protocol HistoryViewModelProtocol: AnyObject {
    var predictions: [Prediction] { get }
    var predictionsPublisher: Published<[Prediction]>.Publisher { get }
    var selectedTab: HistoryTab { get set }
    var isEmpty: Bool { get }
    
    func loadPredictions()
    func deletePrediction(at index: Int)
    func toggleFavorite(at index: Int)
    func selectPrediction(at index: Int)
    func clearHistory()
}

// MARK: - Implementation

final class HistoryViewModel: HistoryViewModelProtocol {
    
    @Published private(set) var predictions: [Prediction] = []
    var predictionsPublisher: Published<[Prediction]>.Publisher { $predictions }
    
    var selectedTab: HistoryTab = .all {
        didSet { loadPredictions() }
    }
    
    var isEmpty: Bool { predictions.isEmpty }
    
    private let storageService: StorageServiceProtocol
    weak var coordinator: MainCoordinatorProtocol?
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
    }
    
    func loadPredictions() {
        switch selectedTab {
        case .all:
            predictions = storageService.getAllPredictions()
        case .favorites:
            predictions = storageService.getFavoritePredictions()
        }
    }
    
    func deletePrediction(at index: Int) {
        guard index < predictions.count else { return }
        let prediction = predictions[index]
        storageService.deletePrediction(id: prediction.id)
        loadPredictions()
    }
    
    func toggleFavorite(at index: Int) {
        guard index < predictions.count else { return }
        let prediction = predictions[index]
        storageService.toggleFavorite(id: prediction.id)
        loadPredictions()
    }
    
    func selectPrediction(at index: Int) {
        guard index < predictions.count else { return }
        let prediction = predictions[index]
        coordinator?.showPredictionDetail(prediction)
    }
    
    func clearHistory() {
        storageService.clearHistory()
        loadPredictions()
    }
}
