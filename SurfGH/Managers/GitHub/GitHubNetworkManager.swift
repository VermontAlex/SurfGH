//
//  APIManager.swift
//  GitHub Viewer
//
//  Created by Oleksandr Oliinyk
//

import Foundation

protocol GitHubNetworkManagerProtocol {
    func gitHubSignIn(responseCode: String,
                      completion: @escaping (Result<GHUserProfileModel, Error>) -> Void)
    func searchForRepos(byName: String, pageNum: Int, token: String, completion: @escaping (Result<RepoSearchResult, Error>) -> Void)
    
}

struct GitHubNetworkManager: GitHubNetworkManagerProtocol {
    
    func gitHubSignIn(responseCode: String,
                      completion: @escaping (Result<GHUserProfileModel, Error>) -> Void) {
        guard let request = GitHubRequestBuilder.getAccessTokenRequest(responseCode: responseCode).request
        else { return }
        
        let operationQueue = OperationQueue()
        var accessToken: GitHubTokenModel?
        
        let tokenOperation = FetchToken(urlRequest: request) { result in
            switch result {
            case .success(let token):
                accessToken = token
            case . failure(let error):
                completion(.failure(error))
            }
        }
        
        tokenOperation.completionBlock = {
            guard let token = accessToken,
                  let request = GitHubRequestBuilder.getUserProfile(accessToken: token).request
            else { return }
            
            let profileOperation = FetchProfile(urlRequest: request,
                                                token: token, completion: completion)
            
            operationQueue.addOperation(profileOperation)
        }
        
        operationQueue.addOperation(tokenOperation)
        
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func searchForRepos(byName: String, pageNum: Int, token: String, completion: @escaping (Result<RepoSearchResult, Error>) -> Void) {
        guard let request = GitHubRequestBuilder.fetchRepoItems(searchBy: byName, page: pageNum, token: token).request else { return }
        let operationQueue = OperationQueue()
        let fetchReposOperation = FetchRepos(urlRequest: request) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        operationQueue.addOperation(fetchReposOperation)
    }
}

private final class FetchToken: BasicSequenceOperation {
    
    init(urlRequest: URLRequest,
         completion: @escaping (Result<GitHubTokenModel, Error>) -> Void) {
        super.init()
        task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
            if let data = data {
                do {
                    let token = try JSONDecoder().decode(GitHubTokenModel.self, from: data)
                        completion(.success(token))
                        self?.state = .finished
                } catch {
                        completion(.failure(error))
                        self?.state = .finished
                }
            } else if let error = error {
                    completion(.failure(error))
                    self?.state = .finished
            }
            self?.state = .finished
        })
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        state = .executing
        
        self.task?.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.task?.cancel()
    }
}

private final class FetchProfile: BasicSequenceOperation {
    
    init(urlRequest: URLRequest, token: GitHubTokenModel,
         completion: @escaping (Result<GHUserProfileModel, Error>) -> Void) {
        super.init()
        task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(GHUserProfileModel.self, from: data)
                       try? KeyChainManager.save(credentials: CredentialsModel(account: profile.login,
                                                                                personalToken: token.accessToken,
                                                                                server: AuthConstants.serviceGH))
                        completion(.success(profile))
                        self?.state = .finished
                } catch {
                        completion(.failure(error))
                        self?.state = .finished
                }
            } else if let error = error {
                    completion(.failure(error))
                    self?.state = .finished
            }
            self?.state = .finished
        })
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        state = .executing
        
        self.task?.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.task?.cancel()
    }
}

private final class FetchRepos: BasicSequenceOperation {
    
    init(urlRequest: URLRequest,
         completion: @escaping (Result<RepoSearchResult, Error>) -> Void) {
        super.init()
        task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
            if let data = data {
                do {
                    let repos = try JSONDecoder().decode(RepoSearchResult.self, from: data)
                        completion(.success(repos))
                        self?.state = .finished
                } catch {
                        completion(.failure(error))
                        self?.state = .finished
                }
            } else if let error = error {
                    completion(.failure(error))
                    self?.state = .finished
            }
            self?.state = .finished
        })
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        state = .executing
        
        self.task?.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.task?.cancel()
    }
}
