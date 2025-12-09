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
    
    private let sections: [(titleKey: String, items: [SettingsItem])] = [
        ("settings_section_profile",   [.editName]),
        ("settings_section_appearance",[.darkMode]),
        ("settings_section_language",  [.language]),
        ("settings_section_data",      [.clearHistory]),
        ("settings_section_about",     [.version, .rateApp])
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
        title = L10n.tr("settings_title")
        
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
            title: L10n.tr("history_clear_title"),
            message: L10n.tr("history_clear_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: L10n.tr("history_clear_cancel"),
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: L10n.tr("history_clear_confirm"),
            style: .destructive
        ) { [weak self] _ in
            self?.storageService.clearHistory()
            self?.showToast(L10n.tr("settings_clear_history_toast"))
        })
        present(alert, animated: true)
    }
    
    private func rateApp() {
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
    
    private func showEditNameAlert() {
        let alert = UIAlertController(
            title: L10n.tr("edit_name_alert_title"),
            message: L10n.tr("edit_name_alert_message"),
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = self.settings.userName
            textField.placeholder = L10n.tr("edit_name_placeholder")
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(
            title: L10n.tr("cancel_button"),
            style: .cancel
        ))
        
        alert.addAction(UIAlertAction(
            title: L10n.tr("edit_name_save"),
            style: .default
        ) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else { return }
            
            self.settings.userName = newName
            self.saveSettings()
            self.tableView.reloadData()
            self.showToast(L10n.tr("name_updated_toast"))
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Settings Item

private enum SettingsItem {
    case editName
    case darkMode
    case language
    case clearHistory
    case version
    case rateApp
    
    var title: String {
        switch self {
        case .editName:    return L10n.tr("settings_edit_name")
        case .darkMode:    return L10n.tr("settings_dark_mode")
        case .language:    return L10n.tr("settings_language")
        case .clearHistory:return L10n.tr("settings_clear_history")
        case .version:     return L10n.tr("settings_version")
        case .rateApp:     return L10n.tr("settings_rate_app")
        }
    }
    
    var icon: String {
        switch self {
        case .editName:     return "person.circle.fill"
        case .darkMode:     return "moon.fill"
        case .language:     return "globe"
        case .clearHistory: return "trash"
        case .version:      return "info.circle.fill"
        case .rateApp:      return "star.fill"
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .editName:     return .systemBlue
        case .darkMode:     return .systemPurple
        case .language:     return .systemTeal
        case .clearHistory: return .systemRed
        case .version:      return .systemGray
        case .rateApp:      return .systemYellow
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
        let sectionInfo = sections[section]
        return L10n.tr(sectionInfo.titleKey)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = item.iconColor
        
        switch item {
        case .version:
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            
        case .language:
            cell.selectionStyle = .none
            let segmented = UISegmentedControl(items: [
                L10n.tr("settings_language_ru_short"),
                L10n.tr("settings_language_en_short")
            ])
            segmented.selectedSegmentIndex = selectedLanguageSegmentIndex()
            segmented.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
            cell.accessoryView = segmented
            
        case .editName, .darkMode, .clearHistory, .rateApp:
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    private func selectedLanguageSegmentIndex() -> Int {
        switch settings.language {
        case .ru: return 0
        case .en: return 1
        case .system:
            let code = Locale.preferredLanguages.first ?? "ru"
            return code.hasPrefix("ru") ? 0 : 1
        }
    }
    
    @objc private func languageChanged(_ sender: UISegmentedControl) {
        let newLanguage: AppLanguage = (sender.selectedSegmentIndex == 0) ? .ru : .en
        settings.language = newLanguage
        saveSettings()
        LanguageManager.shared.currentLanguage = newLanguage
        
        showToast(L10n.tr("settings_language_restart_toast"))
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item {
        case .editName:
            showEditNameAlert()
        case .clearHistory:
            clearHistory()
        case .rateApp:
            rateApp()
        default:
            break
        }
    }
}
