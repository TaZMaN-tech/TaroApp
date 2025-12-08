//
//  SettingsViewController.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backgroundView: GradientView = {
        let view = GradientView()
        view.colors = [Design.Colors.gradientStart, Design.Colors.gradientEnd]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    
    private let storageService: StorageServiceProtocol
    private var settings: UserSettings
    
    private let sections: [(title: String, items: [SettingsItem])] = [
        ("Внешний вид", [.darkMode]),
        ("Данные", [.clearHistory]),
        ("О приложении", [.version, .rateApp])
    ]
    
    // MARK: - Init
    
    init(storageService: StorageServiceProtocol = StorageService.shared) {
        self.storageService = storageService
        self.settings = storageService.getUserSettings()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Настройки"
        
        // Кнопка назад (если стандартная не работает)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        view.addSubview(backgroundView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func saveSettings() {
        storageService.saveUserSettings(settings)
    }
    
    private func clearHistory() {
        let alert = UIAlertController(
            title: "Очистить историю?",
            message: "Избранные расклады сохранятся",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Очистить", style: .destructive) { [weak self] _ in
            self?.storageService.clearHistory()
            self?.showToast("История очищена")
        })
        present(alert, animated: true)
    }
    
    private func rateApp() {
        // TODO: Заменить на реальный App Store ID
        if let url = URL(string: "https://apps.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.textAlignment = .center
        toast.font = Design.Fonts.caption
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - Settings Item

private enum SettingsItem {
    case darkMode
    case clearHistory
    case version
    case rateApp
    
    var title: String {
        switch self {
        case .darkMode: return "Тёмная тема"
        case .clearHistory: return "Очистить историю"
        case .version: return "Версия"
        case .rateApp: return "Оценить приложение"
        }
    }
    
    var icon: String {
        switch self {
        case .darkMode: return "moon.fill"
        case .clearHistory: return "trash"
        case .version: return "info.circle.fill"
        case .rateApp: return "star.fill"
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .darkMode: return .systemIndigo
        case .clearHistory: return .systemRed
        case .version: return .systemBlue
        case .rateApp: return .systemYellow
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = item.iconColor
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        switch item {
        case .darkMode:
            let toggle = UISwitch()
            toggle.isOn = settings.isDarkMode
            toggle.addTarget(self, action: #selector(darkModeToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            
        case .clearHistory:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .systemRed
            
        case .version:
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            cell.detailTextLabel?.text = "\(version) (\(build))"
            cell.selectionStyle = .none
            
        case .rateApp:
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    @objc private func darkModeToggled(_ sender: UISwitch) {
        settings.isDarkMode = sender.isOn
        saveSettings()
        
        // Применяем тему
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.animate(withDuration: 0.3) {
                window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item {
        case .clearHistory:
            clearHistory()
        case .rateApp:
            rateApp()
        default:
            break
        }
    }
}
