//
//  AuthGitHubModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Foundation

struct LoginGitHubModel: Codable {
    
    let grantType: String =  AuthConstants.grantType
    let code: String
    let clientId: String = AuthConstants.cliendIdGH
    let clientSecret: String = AuthConstants.clientSecretGH
    let state: String? = nil
    
    private enum CodingKeys : String, CodingKey {
        case grantType = "grant_type", code = "code", clientId = "client_id", clientSecret = "client_secret", state = "state"
    }
}
