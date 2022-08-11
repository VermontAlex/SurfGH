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
    let incompleteResults: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct RepoItemModel: Codable {
    let id: Int?
    let name, fullName: String
    let itemPrivate: Bool?
    let owner: RepoOwner
    let htmlURL: String?
    let itemDescription: String?
    let stargazersCount: Int
    let forksCount: Int?
    var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case itemPrivate = "private"
        case owner
        case htmlURL = "html_url"
        case itemDescription = "description"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
    }
}

struct RepoOwner: Codable {
    let login: String
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case login, id
    }
}
