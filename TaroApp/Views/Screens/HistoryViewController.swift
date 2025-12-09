//
//  HistoryViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit
import Combine

final class HistoryViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            L10n.tr("history_tab_all"),
            L10n.tr("history_tab_favorites")
        ])
        
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        
        // Pull-to-Refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.refreshControl = refreshControl
        
        return table
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var backgroundView: GradientView = {
        let view = GradientView()
        view.colors = [Design.Colors.gradientStart, Design.Colors.gradientEnd]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: HistoryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: HistoryViewModelProtocol) {
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
        setupBindings()
        viewModel.loadPredictions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.loadPredictions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = L10n.tr("history_title")
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        
        view.addSubview(backgroundView)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.predictionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if isEmpty {
            let isAllTab = viewModel.selectedTab == .all
            emptyStateView.configure(
                icon: isAllTab ? "🔮" : "❤️",
                title: isAllTab ? L10n.tr("history_empty_all_title") : L10n.tr("history_empty_favorites_title")
            )
        }
    }
    
    // MARK: - Actions
    
    @objc private func segmentChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
        viewModel.selectedTab = HistoryTab(rawValue: segmentedControl.selectedSegmentIndex) ?? .all
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: L10n.tr("history_clear_title"),
            message: L10n.tr("history_clear_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.tr("history_clear_cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.tr("history_clear_confirm"), style: .destructive) { [weak self] _ in
            self?.viewModel.clearHistory()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        })
        present(alert, animated: true)
    }
    
    @objc private func refreshData() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.loadPredictions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        let prediction = viewModel.predictions[indexPath.row]
        cell.configure(with: prediction)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.selectPrediction(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let prediction = viewModel.predictions[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            self?.viewModel.deletePrediction(at: indexPath.row)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self?.viewModel.toggleFavorite(at: indexPath.row)
            completion(true)
        }
        favoriteAction.image = UIImage(systemName: prediction.isFavorite ? "heart.slash.fill" : "heart.fill")
        favoriteAction.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction])
    }
}

// MARK: - History Cell

final class HistoryCell: UITableViewCell {
    
    static let identifier = "HistoryCell"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.cardBackground
        view.layer.cornerRadius = Design.CornerRadius.medium
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.12
        view.layer.borderWidth = 1
        view.layer.borderColor = Design.Colors.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Fonts.caption
        label.textColor = Design.Colors.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Fonts.small
        label.textColor = Design.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = Design.Colors.textSecondary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteIcon: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.font = UIFont.systemFont(ofSize: 18)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(separatorLine)
        containerView.addSubview(cardsLabel)
        containerView.addSubview(favoriteIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),
            
            favoriteIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            favoriteIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            cardsLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            cardsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            cardsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            cardsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with prediction: Prediction) {
        iconLabel.text = prediction.spreadType.icon
        let format = L10n.tr("history_cell_title_format")
        titleLabel.text = String(format: format, prediction.spreadType.title, prediction.userName)
        
        dateLabel.text = HistoryCell.dateFormatter.string(from: prediction.createdAt)
        
        // Форматируем карты
        let cardNames = prediction.cards.map { card in
            card.isReversed ? "\(card.name) ⟲" : card.name
        }.joined(separator: " • ")
        cardsLabel.text = "🃏 \(cardNames)"
        
        favoriteIcon.isHidden = !prediction.isFavorite
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.borderColor = Design.Colors.separator.cgColor
        }
    }
}
