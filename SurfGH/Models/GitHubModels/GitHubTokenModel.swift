//
//  GitHubTokenModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Foundation

struct GitHubTokenModel: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}
