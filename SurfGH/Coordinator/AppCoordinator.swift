//
//  AppCoordinator.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

enum NextTabCoordinator {
    case authTab
    case homeTab(profile: AccountViewModelProtocol)
}

final class AppCoordinator: NSObject, CoordinatorProtocol, UINavigationControllerDelegate {
    
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        goToAuthCoordinator()
    }
    
    func goToAuthCoordinator() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    func goToHomeTabCoordinator(with profile: AccountViewModelProtocol) {
        let homeTabCoordinator = HomeTabCoordinator(navigationController: navigationController,
                                                    profile: profile)
        homeTabCoordinator.parentCoordinator = self
        childCoordinators.append(homeTabCoordinator)
        homeTabCoordinator.start()
    }
    
    func childDidFinish(_ coordinator : CoordinatorProtocol?, moveToNext: NextTabCoordinator? = nil) {
        // Call this if a coordinator is done.
        for (index, child) in childCoordinators.enumerated() {
            if child === coordinator {
                childCoordinators.remove(at: index)
                navigationController.viewControllers.remove(at: index)
                break
            }
        }
        guard let coordinator = moveToNext else { return }
        moveTo(coordinator: coordinator)
    }
    
    private func moveTo(coordinator: NextTabCoordinator) {
        switch coordinator {
        case .authTab:
            goToAuthCoordinator()
        case .homeTab(let profile):
            goToHomeTabCoordinator(with: profile)
        }
    }
}
