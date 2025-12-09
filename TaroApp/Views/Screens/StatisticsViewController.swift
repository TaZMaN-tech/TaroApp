//
//  StatisticsViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 09.12.2025.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    
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
    
    // Статистика
    private let storageService: StorageServiceProtocol
    private var predictions: [Prediction] = []
    
    // MARK: - Init
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        loadStatistics()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = L10n.tr("statistics_title")
        view.backgroundColor = .systemBackground
        
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func loadStatistics() {
        predictions = storageService.getAllPredictions()
        buildStatisticsUI()
    }
    
    private func buildStatisticsUI() {
        // Очищаем предыдущий контент
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var previousView: UIView?
        let spacing: CGFloat = 16
        
        // 1. Общая статистика
        let totalCard = createStatCard(
            icon: "🔮",
            title: L10n.tr("stats_total_readings"),
            value: "\(predictions.count)",
            color: UIColor.systemPurple
        )
        contentView.addSubview(totalCard)
        totalCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing).isActive = true
        totalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        totalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        previousView = totalCard
        
        // 2. Избранные
        let favoritesCount = predictions.filter { $0.isFavorite }.count
        let favCard = createStatCard(
            icon: "⭐",
            title: L10n.tr("stats_favorites"),
            value: "\(favoritesCount)",
            color: UIColor.systemOrange
        )
        contentView.addSubview(favCard)
        favCard.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: spacing).isActive = true
        favCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        favCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        previousView = favCard
        
        // 3. Самый популярный тип
        if let mostPopular = getMostPopularSpreadType() {
            let popCard = createStatCard(
                icon: mostPopular.icon,
                title: L10n.tr("stats_most_popular"),
                value: mostPopular.title,
                color: UIColor.systemPink
            )
            contentView.addSubview(popCard)
            popCard.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: spacing).isActive = true
            popCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
            popCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
            previousView = popCard
        }
        
        // 4. Распределение по типам
        let distributionCard = createDistributionCard()
        contentView.addSubview(distributionCard)
        distributionCard.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: spacing).isActive = true
        distributionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        distributionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        previousView = distributionCard
        
        // 5. Самая частая карта
        if let mostFrequentCard = getMostFrequentCard() {
            let cardCard = createStatCard(
                icon: "🃏",
                title: L10n.tr("stats_most_frequent_card"),
                value: mostFrequentCard,
                color: UIColor.systemBlue
            )
            contentView.addSubview(cardCard)
            cardCard.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: spacing).isActive = true
            cardCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
            cardCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
            previousView = cardCard
        }
        
        // 6. Активность за последние 7 дней
        let activityCard = createActivityCard()
        contentView.addSubview(activityCard)
        activityCard.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: spacing).isActive = true
        activityCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        activityCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        activityCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing).isActive = true
    }
    
    // MARK: - Card Creation
    
    private func createStatCard(icon: String, title: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = Design.Colors.cardBackground
        container.layer.cornerRadius = Design.CornerRadius.large
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 48)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Design.Fonts.caption
        titleLabel.textColor = Design.Colors.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = color
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 120),
            
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        return container
    }
    
    private func createDistributionCard() -> UIView {
        let container = UIView()
        container.backgroundColor = Design.Colors.cardBackground
        container.layer.cornerRadius = Design.CornerRadius.large
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.tr("stats_distribution")
        titleLabel.font = Design.Fonts.title
        titleLabel.textColor = Design.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20)
        ])
        
        // Создаём бары для каждого типа
        let distribution = getSpreadTypeDistribution()
        var previousBar: UIView?
        
        for (spreadType, count) in distribution {
            let barContainer = createBarView(
                icon: spreadType.icon,
                title: spreadType.title,
                count: count,
                total: predictions.count
            )
            container.addSubview(barContainer)
            
            if let prev = previousBar {
                barContainer.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 12).isActive = true
            } else {
                barContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
            }
            
            barContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
            barContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
            previousBar = barContainer
        }
        
        if let lastBar = previousBar {
            container.bottomAnchor.constraint(equalTo: lastBar.bottomAnchor, constant: 20).isActive = true
        }
        
        return container
    }
    
    private func createBarView(icon: String, title: String, count: Int, total: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Design.Fonts.small
        titleLabel.textColor = Design.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = Design.Fonts.small
        countLabel.textColor = Design.Colors.textSecondary
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let barBackground = UIView()
        barBackground.backgroundColor = Design.Colors.separator
        barBackground.layer.cornerRadius = 4
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let barFill = UIView()
        barFill.backgroundColor = Design.Colors.gradientStart
        barFill.layer.cornerRadius = 4
        barFill.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        container.addSubview(countLabel)
        container.addSubview(barBackground)
        barBackground.addSubview(barFill)
        
        let percentage = total > 0 ? CGFloat(count) / CGFloat(total) : 0
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            barBackground.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            barBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            barBackground.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -12),
            barBackground.heightAnchor.constraint(equalToConstant: 8),
            
            barFill.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
            barFill.topAnchor.constraint(equalTo: barBackground.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
            barFill.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: percentage),
            
            countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        return container
    }
    
    private func createActivityCard() -> UIView {
        let container = UIView()
        container.backgroundColor = Design.Colors.cardBackground
        container.layer.cornerRadius = Design.CornerRadius.large
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.tr("stats_activity_7_days")
        titleLabel.font = Design.Fonts.title
        titleLabel.textColor = Design.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let graphContainer = createActivityGraph()
        
        container.addSubview(titleLabel)
        container.addSubview(graphContainer)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            
            graphContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            graphContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            graphContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            graphContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    private func createActivityGraph() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let activity = getLast7DaysActivity()
        let maxCount = activity.map { $0.1 }.max() ?? 1
        
        let barWidth: CGFloat = 40
        let spacing: CGFloat = 8
        
        for (index, (day, count)) in activity.enumerated() {
            let barContainer = UIView()
            barContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let barHeight = maxCount > 0 ? (CGFloat(count) / CGFloat(maxCount)) * 80 : 0
            
            let bar = UIView()
            bar.backgroundColor = Design.Colors.gradientStart
            bar.layer.cornerRadius = 4
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            let dayLabel = UILabel()
            dayLabel.text = day
            dayLabel.font = UIFont.systemFont(ofSize: 10)
            dayLabel.textColor = Design.Colors.textSecondary
            dayLabel.textAlignment = .center
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            
            barContainer.addSubview(bar)
            barContainer.addSubview(dayLabel)
            container.addSubview(barContainer)
            
            NSLayoutConstraint.activate([
                barContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: CGFloat(index) * (barWidth + spacing)),
                barContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                barContainer.widthAnchor.constraint(equalToConstant: barWidth),
                barContainer.heightAnchor.constraint(equalToConstant: 100),
                
                bar.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: dayLabel.topAnchor, constant: -4),
                bar.heightAnchor.constraint(equalToConstant: max(barHeight, 4)),
                
                dayLabel.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
                dayLabel.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor),
                dayLabel.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
            ])
        }
        
        return container
    }
    
    // MARK: - Statistics Logic
    
    private func getMostPopularSpreadType() -> SpreadType? {
        let distribution = getSpreadTypeDistribution()
        return distribution.max(by: { $0.value < $1.value })?.key
    }
    
    private func getSpreadTypeDistribution() -> [SpreadType: Int] {
        var distribution: [SpreadType: Int] = [:]
        for prediction in predictions {
            distribution[prediction.spreadType, default: 0] += 1
        }
        return distribution.sorted(by: { $0.value > $1.value }).reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
    private func getMostFrequentCard() -> String? {
        var cardCounts: [String: Int] = [:]
        for prediction in predictions {
            for card in prediction.cards {
                cardCounts[card.name, default: 0] += 1
            }
        }
        return cardCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getLast7DaysActivity() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        var activity: [(String, Int)] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayName = dateFormatter.string(from: date)
            
            let count = predictions.filter { prediction in
                calendar.isDate(prediction.createdAt, inSameDayAs: date)
            }.count
            
            activity.append((dayName, count))
        }
        
        return activity
    }
}
