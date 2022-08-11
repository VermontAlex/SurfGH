//
//  APIType.swift
//  GitHub Viewer
//
//  Created by Oleksandr Oliinyk
//

import Foundation

enum GitHubRequestBuilder {

    case getAccessTokenRequest(responseCode: String)
    case getAuthRequest(cliendId: String)
    case getUserProfile(accessToken: GitHubTokenModel)
    case fetchRepoItems(searchBy: String, page: Int, token: String)
    
    struct ParamsConstants {
        static let clientId = "client_id"
        static let state = "state"
        static let query = "q"
        static let perPage = "per_page"
        static let sort = "sort"
        static let page = "page"
        static let tokenType = "Bearer" + " "
    }
    
    private var baseUrl: String {
        return "https://github.com/"
    }
    
    private var apiGHUrl: String {
        return "https://api.github.com"
    }
    
    private var path: String {
        switch self {
        case .getAccessTokenRequest:
             return "/login/oauth/access_token"
        case .getAuthRequest:
            return "/login/oauth/authorize"
        case .getUserProfile:
            return "/user"
        case .fetchRepoItems:
            return "/search/repositories"
        }
    }
    
    private var method: String? {
        switch self {
        case .getAccessTokenRequest:
            return "POST"
        default:
            return nil
        }
    }
    
    var request: URLRequest? {
        switch self {
        case .getAuthRequest(let cliendId):
            guard let url = formSignInUrl(cliendId: cliendId) else { return nil }
            return URLRequest(url: url)
        case .getAccessTokenRequest(let responseCode):
            guard let url = URL(string: path, relativeTo: URL(string: baseUrl)) else { return nil }
            let httpBody = try? JSONEncoder().encode(LoginGitHubModel(code: responseCode))
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        case .getUserProfile(let token):
            guard let url = URL(string: path, relativeTo: URL(string: apiGHUrl)) else { return nil }
            var request = URLRequest(url: url)
            request.addValue(ParamsConstants.tokenType + token.accessToken, forHTTPHeaderField: "Authorization")
            
            return request
        case .fetchRepoItems(let searchBy, let page, let token):
            guard let url = formFetchRepoItemsUrl(searchBy: searchBy, page: page) else { return nil }
            var request = URLRequest(url: url)
            request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.addValue(ParamsConstants.tokenType + token, forHTTPHeaderField: "Authorization")
            
            return request
        }
    }

    private func formSignInUrl(cliendId: String) -> URL? {
        guard let url = URL(string: baseUrl) else { return nil }
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        components.scheme = url.scheme
        components.host = url.host
        components.path = path
        
        queryItems.append(URLQueryItem(name: ParamsConstants.clientId, value: cliendId))
        queryItems.append(URLQueryItem(name: ParamsConstants.state, value: UUID().uuidString))
        
        components.queryItems = queryItems
        
        return components.url
    }
    
    private func formFetchRepoItemsUrl(searchBy: String, page: Int) -> URL? {
        guard let url = URL(string: apiGHUrl) else { return nil }
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        components.scheme = url.scheme
        components.host = url.host
        components.path = path
        
        queryItems.append(URLQueryItem(name: ParamsConstants.query, value: searchBy))
        queryItems.append(URLQueryItem(name: ParamsConstants.sort, value: "stars"))
        queryItems.append(URLQueryItem(name: ParamsConstants.perPage, value: "15"))
        queryItems.append(URLQueryItem(name: ParamsConstants.page, value: String(page)))
        
        components.queryItems = queryItems
        
        return components.url
    }
}
