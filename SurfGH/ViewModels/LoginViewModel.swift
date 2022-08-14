//
//  LoginViewModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

struct LoginViewModel {
    
    let title: String = "Please signIn with GitHub Account."
    let titleConnection = "Network connection isn't available, please switch it on or try again later."
    var gitApiManager: GitHubNetworkManagerProtocol? = GitHubNetworkManager()
    
    var isAbleConnection: Bool {
        get {
            InternetReachability.isConnectedToNetwork()
        }
    }
}
