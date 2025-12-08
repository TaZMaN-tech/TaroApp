//
//  PredictionViewModel.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import Foundation
import Combine

// MARK: - Protocol

protocol PredictionViewModelProtocol: AnyObject {
    var state: LoadingState<Prediction> { get }
    var statePublisher: Published<LoadingState<Prediction>>.Publisher { get }
    var cards: [TarotCard] { get }
    var spreadType: SpreadType { get }
    var userName: String { get }
    
    func loadPrediction()
    func toggleFavorite()
    func sharePrediction() -> String?
    func dismiss()
}

// MARK: - Implementation

final class PredictionViewModel: PredictionViewModelProtocol {
    
    @Published private(set) var state: LoadingState<Prediction> = .idle
    var statePublisher: Published<LoadingState<Prediction>>.Publisher { $state }
    
    private(set) var cards: [TarotCard] = []
    let spreadType: SpreadType
    let userName: String
    
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    weak var coordinator: MainCoordinatorProtocol?
    
    private var currentPredictionId: UUID?
    
    init(
        spreadType: SpreadType,
        userName: String,
        networkService: NetworkServiceProtocol = NetworkService.shared,
        storageService: StorageServiceProtocol = StorageService.shared
    ) {
        self.spreadType = spreadType
        self.userName = userName
        self.networkService = networkService
        self.storageService = storageService
    }
    
    func loadPrediction() {
        cards = TarotCard.randomCards(count: 3)
        state = .loading
        
        let language = Locale.current.language.languageCode?.identifier ?? "ru"
        
        Task { @MainActor in
            do {
                let text = try await networkService.getPrediction(
                    cards: cards,
                    name: userName,
                    spreadType: spreadType,
                    language: language
                )
                
                let prediction = Prediction(
                    userName: userName,
                    spreadType: spreadType,
                    cards: cards,
                    text: text
                )
                
                storageService.savePrediction(prediction)
                currentPredictionId = prediction.id
                
                state = .loaded(prediction)
                
            } catch {
                state = .error(error)
            }
        }
    }
    
    func toggleFavorite() {
        guard let id = currentPredictionId else { return }
        storageService.toggleFavorite(id: id)
        
        if case .loaded(var prediction) = state {
            prediction.isFavorite.toggle()
            state = .loaded(prediction)
        }
    }
    
    func sharePrediction() -> String? {
        guard case .loaded(let prediction) = state else { return nil }
        
        let cardsText = prediction.cards.map { $0.displayName }.joined(separator: ", ")
        
        return """
        🔮 Мой расклад Таро: \(prediction.spreadType.title)
        
        Карты: \(cardsText)
        
        \(prediction.text)
        
        — TaroApp ✨
        """
    }
    
    func dismiss() {
        coordinator?.dismissPrediction()
    }
}
