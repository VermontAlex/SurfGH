//
//  RepoItemModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Foundation

struct RepoSearchResult: Codable {
    let totalCount: Int
    let items: [RepoItemModel]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct RepoItemModel: Codable {
    let name, fullName: String
    let owner: RepoOwner
    let htmlURL: String?
    let itemDescription: String?
    let stargazersCount: Int
    var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case itemDescription = "description"
        case stargazersCount = "stargazers_count"
    }
}

struct RepoOwner: Codable {
    let login: String

    enum CodingKeys: String, CodingKey {
        case login
    }
}
