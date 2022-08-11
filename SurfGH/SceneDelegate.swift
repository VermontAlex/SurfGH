//
//  SceneDelegate.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let navController = UINavigationController()
        coordinator = AppCoordinator(navigationController: navController)
        coordinator?.start()
        
        let appWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene
        appWindow.rootViewController = navController
        appWindow.makeKeyAndVisible()
        
        window = appWindow
    }
}
