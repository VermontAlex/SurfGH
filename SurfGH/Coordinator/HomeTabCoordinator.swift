//
//  HomeTabCoordinator.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

final class HomeTabCoordinator: CoordinatorProtocol {
    
    weak var parentCoordinator: AppCoordinator?
    var childCoordinators: [CoordinatorProtocol] = []
    
    var navigationController: UINavigationController
    var viewModel: HomeTabViewModel?
    
    init(navigationController : UINavigationController, viewModel: HomeTabViewModel?) {
        self.navigationController = navigationController
        navigationController.view = RootDefaultView()
        self.viewModel = viewModel
    }
    
    func start() {
        let transitionAnimation = CustomTransitionAnimaionHomePage(transitionDuration: 1)
        let transitionManager = CustomTransitionManager(transitionAnimation: transitionAnimation)
        viewModel?.customTransition = transitionManager
        
        let vc = HomeTabPageVC.instantiateCustom(storyboard: HomeTabPageVC.storyboardName)
        vc.modalPresentationStyle = .fullScreen
        vc.coordinator = self
        vc.viewModel = viewModel
        navigationController.present(vc, animated: true)
    }
    
    func stop(andMoveTo: NextTabCoordinator? = nil) {
        parentCoordinator?.childDidFinish(self, moveToNext: andMoveTo)
    }
}
