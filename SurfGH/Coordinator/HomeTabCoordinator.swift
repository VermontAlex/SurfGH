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
    let profile: AccountViewModelProtocol
    
    init(navigationController : UINavigationController, profile: AccountViewModelProtocol) {
        self.navigationController = navigationController
        navigationController.view = RootDefaultView()
        self.profile = profile
    }
    
    func start() {
        let vc = HomeTabPageVC.instantiateCustom(storyboard: HomeTabPageVC.storyboardName)
        vc.modalPresentationStyle = .fullScreen
        vc.coordinator = self
        vc.viewModel = createHomeTabViewModel()
        
        navigationController.present(vc, animated: true)
    }
    
    func stop(andMoveTo: NextTabCoordinator? = nil) {
        parentCoordinator?.childDidFinish(self, moveToNext: andMoveTo)
    }
    
    private func createHomeTabViewModel() -> HomeTabViewModel {
        let transitionAnimation = CustomTransitionAnimaionHomePage(transitionDuration: 1)
        let transitionManager = CustomTransitionManager(transitionAnimation: transitionAnimation)
        let homeViewModel = HomeTabViewModel(account: profile,
                                             service: AuthConstants.serviceGH,
                                             customTransition: transitionManager,
                                             gitManager: GitHubNetworkManager(),
                                             coreDataManager: CoreDataManager())
        return homeViewModel
    }
}
