//
//  SceneDelegate.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 19.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator: MainCoordinator?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let navigationController = UINavigationController()
        
        let coordinator = MainCoordinator(navigationController: navigationController)
        self.coordinator = coordinator
        coordinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // Применяем сохранённую тему
        ThemeManager.shared.applyTheme()
    }
}
