//
//  HomePageViewModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

class HomeTabViewModel {
    
    let account: AccountViewModelProtocol
    let service: String
    var paginationNumber: Int = 1
    var searchByWord: String = ""
    var customTransition: UIViewControllerTransitioningDelegate?
    
    var tokenToUse: String? {
        get {
            return retreiveToken()
        }
    }
    
    init(account: AccountViewModelProtocol, service: String, customTransition: UIViewControllerTransitioningDelegate? = nil) {
        self.account = account
        self.service = service
        self.customTransition = customTransition
    }
    
    private func retreiveToken() -> String? {
        do {
            let result = try KeyChainManager.get(account: account.login, service: service)
            return String(data: result, encoding: String.Encoding.utf8)
        } catch(let keyError) {
            return keyError.localizedDescription
        }
    }
}
