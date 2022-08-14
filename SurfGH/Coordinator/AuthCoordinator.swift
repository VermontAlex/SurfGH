//
//  MainCoordinator.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

final class AuthCoordinator: NSObject, CoordinatorProtocol, UINavigationControllerDelegate {
    
    weak var parentCoordinator: AppCoordinator?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.overrideUserInterfaceStyle = .light
    }
    
    func start() {
        let vc = LoginPageVC.instantiateCustom(storyboard: LoginPageVC.storyboardName)
        vc.coordinator = self
        vc.viewModel = LoginViewModel()
        navigationController.pushViewController(vc, animated: true)
    }

    func stop(andMoveTo: NextTabCoordinator? = nil) {
        parentCoordinator?.childDidFinish(self, moveToNext: andMoveTo)
    }
}
