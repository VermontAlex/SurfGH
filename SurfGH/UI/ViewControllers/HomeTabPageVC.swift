//
//  ViewController.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Combine
import UIKit
import SafariServices

protocol RepoSelectedDelegate: AnyObject {
    func repoSelected(vm: RepoItemCellViewModel,_ isSelected: Bool)
}

class HomeTabPageVC: UIViewController, StoryboardedProtocol {
    
    static let identifier = "HomeTabPageVC"
    static let storyboardName = "HomeTabPage"
    
    @IBOutlet var repoTableView: UITableView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return indicator
    }()
    
    private var searchedRepo = [RepoItemCellViewModel]()
    private let dispatchGroup = DispatchGroup()
    private var sinkSet = Set<AnyCancellable>()
    private var defaultSearch: String = ""
    private var searchedText: String {
        get {
            if defaultSearch.isEmpty {
                return "GitHub-Viewer"
            } else {
                return defaultSearch
            }
        }
        
        set {
            defaultSearch = newValue
        }
    }
    
    var viewModel: HomeTabViewModel?
    weak var delegate: RepoSelectedDelegate?
    weak var coordinator: CoordinatorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        welcomeFillingHomePage()
        tableViewInitialFilling()
    }
    
    private func configureTableView() {
        repoTableView.delegate = self
        repoTableView.dataSource = self
        repoTableView.separatorColor = .clear
        repoTableView.allowsMultipleSelection = false
        repoTableView.register(RepoTableItemCell.nib(), forCellReuseIdentifier: RepoTableItemCell.cellReuseIdentifier)
        repoTableView.tableFooterView = activityIndicator
    }
    
    private func tableViewInitialFilling() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.searchByWord = searchedText
        viewModel.paginationNumber = 1
        activityIndicator.startAnimating()
        DispatchQueue.main.async {
            self.sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: viewModel.searchByWord)
        }
    }
    
    private func sequentlyFillingTable(pagination: Int, searchedWord: String) {
        guard let viewModel = viewModel,
              let dataToken = try? KeyChainManager.get(account: viewModel.account.login, service: viewModel.service),
              let token = String(data: dataToken, encoding: String.Encoding.utf8) else {
                  return
              }
        
        let firstPartResult = performGetReposRequest(searchedWord: searchedWord, page: pagination, token: token)
        let secondPartResult = performGetReposRequest(searchedWord: searchedWord, page: pagination + 1, token: token)
        
        let dispatchWorkItem = DispatchWorkItem {
            let result = firstPartResult + secondPartResult
            self.searchedRepo.append(contentsOf: result)
            DispatchQueue.main.async {
                self.repoTableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        
        dispatchGroup.notify(queue: .global(), work: dispatchWorkItem)
    }
    
    private func performGetReposRequest(searchedWord: String, page: Int, token: String) -> [RepoItemCellViewModel] {
        guard let viewModel = viewModel, let gitManager = viewModel.gitManager else { return [] }
        var getResult = [RepoItemCellViewModel]()
        
        dispatchGroup.enter()
        gitManager.searchForRepos(byName: searchedWord,
                                  pageNum: page,
                                  token: token) { result in
            switch result {
            case .success(let repos):
                let reposViewModel = repos.items.map { repo in
                    return RepoItemCellViewModel(repo: repo)
                }
                getResult = reposViewModel
                if page % 2 != 0 {
                    viewModel.paginationNumber += 2
                }
                self.dispatchGroup.leave()
            case .failure(let error):
                ErrorHandlerService.unknownedError(error).handleErrorWithDB()
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
        DispatchQueue.global().async {
            self.saveRepoToCD(repos: getResult)
        }
        return getResult
    }
    
    private func saveRepoToCD(repos: [RepoItemCellViewModel]) {
        guard let viewModel = viewModel else { return }
        viewModel.coreDataManager?.saveRepos(repos: repos.map{ $0.repo })
    }
    
    private func welcomeFillingHomePage() {
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        guard let viewModel = viewModel else { return fillHomeTabDefault() }
        welcomeLabel.text = "Hello, \(viewModel.account.login)!"
        welcomeLabel.font = UIFont.sf(style: .bold, size: 50)
        self.transitioningDelegate = viewModel.customTransition
    }
    
    private func fillHomeTabDefault() {
        welcomeLabel.font = UIFont.sf(style: .bold, size: 20)
        welcomeLabel.text = "Welcome!"
    }
    
    private func createViewCanceledSearchOnTapAnyPlace() {
        let viewTouchIndicator = TouchedView()
        viewTouchIndicator.backgroundColor = .clear
        viewTouchIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewTouchIndicator.resignViewPublisher.sink { action in
            self.searchBar.resignFirstResponder()
            self.performSearchRepositories()
        }.store(in: &sinkSet)
        
        self.view.addSubview(viewTouchIndicator)
        let constraints: [NSLayoutConstraint] = [
            viewTouchIndicator.topAnchor.constraint(equalTo: self.welcomeLabel.topAnchor),
            viewTouchIndicator.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            viewTouchIndicator.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            viewTouchIndicator.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func openUrlInSafari(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    private func performSearchRepositories() {
        guard let viewModel = viewModel else { return }
        viewModel.searchByWord = searchedText
        viewModel.paginationNumber = 1
        
        searchedRepo.removeAll()
        repoTableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        viewModel.searchByWord = searchedText
        DispatchQueue.global().async {
            viewModel.coreDataManager?.deleteAllCDRepos()
        }
        DispatchQueue.main.async {
            self.sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: self.searchedText)
        }
    }
    
    @IBAction func searchRepoButton(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        performSearchRepositories()
    }
    
    @IBAction func watchedReposButtonTapped(_ sender: Any) {
        let vc = WatchedReposPageVC.instantiateCustom(storyboard: WatchedReposPageVC.storyboardName)
        vc.coreDataManager = viewModel?.coreDataManager
        self.present(vc, animated: true, completion: nil)
    }
}

extension HomeTabPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchedRepo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repoTableView.dequeueReusableCell(withIdentifier: RepoTableItemCell.cellReuseIdentifier, for: indexPath)
        if let cell = cell as? RepoTableItemCell {
            let viewModel = searchedRepo[indexPath.row]
            cell.setupWith(viewModel: viewModel)
            cell.delegate = self
            self.delegate = cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        DispatchQueue.main.async {
            guard self.searchedRepo.count - 5 < indexPath.row, let viewModel = self.viewModel else { return }
            self.sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: viewModel.searchByWord)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRepo = self.searchedRepo[indexPath.row]
        guard let selectedRepoUrl = URL(string: selectedRepo.repo.htmlURL ?? "") else { return }
        self.delegate?.repoSelected(vm: selectedRepo,true)
        self.openUrlInSafari(url: selectedRepoUrl)
        self.viewModel?.coreDataManager?.updateRepoToWatched(repo: selectedRepo.repo)
        
        tableView.reloadData()
    }
}

extension HomeTabPageVC: RepoItemCellDelegate {
    
    func updateCellHeight(vm: RepoItemCellViewModel?, inBlock: () -> Void) {
        
        if let vm = vm {
            for cellViewModel in searchedRepo {
                if cellViewModel === vm {
                    continue
                }
                
                cellViewModel.expanded = false
            }
        }
        
        inBlock()
        repoTableView.reloadData()
    }
}

extension HomeTabPageVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        createViewCanceledSearchOnTapAnyPlace()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedText = searchText
    }
}
