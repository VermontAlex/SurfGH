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
    
    @IBOutlet var repoTableView: UITableView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        return indicator
    }()
    
    static let identifier = "HomeTabPageVC"
    static let storyboardName = "HomeTabPage"
    
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
    private let gitManager = GitHubNetworkManager()
    private let coreDataManager = CoreDataManager()
    private var searchedRepo = [RepoItemCellViewModel]()
    weak var delegate: RepoSelectedDelegate?
    weak var coordinator: CoordinatorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        repoTableView.allowsMultipleSelection = false
        fillHomeTab()
        initialFillTheTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureTableView()
    }
    
    private func configureTableView() {
        repoTableView.delegate = self
        repoTableView.dataSource = self
        repoTableView.separatorColor = .clear
        repoTableView.register(RepoTableItemCell.nib(), forCellReuseIdentifier: RepoTableItemCell.cellReuseIdentifier)
        repoTableView.tableFooterView = activityIndicator
    }
    
    private func initialFillTheTable() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.searchByWord = searchedText
        viewModel.paginationNumber = 1
        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            self.sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: viewModel.searchByWord)
        }
    }
    
    private func sequentlyFillingTable(pagination: Int, searchedWord: String) {
        guard let viewModel = viewModel,
              let dataToken = try? KeyChainManager.get(account: viewModel.account.login, service: viewModel.service),
              let token = String(data: dataToken, encoding: String.Encoding.utf8) else {
                  return
              }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        gitManager.searchForRepos(byName: searchedWord,
                                  pageNum: pagination,
                                  token: token) { result in
            switch result {
            case .success(let repos):
                let reposViewModel = repos.items.map { repo in
                    return RepoItemCellViewModel(repo: repo)
                }
                self.searchedRepo.append(contentsOf: reposViewModel)
                dispatchGroup.leave()
            case .failure(let error):
                ErrorHandlerService.unknownedError(error).handleErrorWithDB()
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        dispatchGroup.enter()
        
        gitManager.searchForRepos(byName: searchedWord,
                                  pageNum: pagination + 1,
                                  token: token) { result in
            switch result {
            case .success(let repos):
                let reposViewModel = repos.items.map { repo in
                    return RepoItemCellViewModel(repo: repo)
                }
                self.searchedRepo.append(contentsOf: reposViewModel)
                viewModel.paginationNumber += 2
                dispatchGroup.leave()
            case .failure(let error):
                ErrorHandlerService.unknownedError(error).handleErrorWithDB()
                dispatchGroup.leave()
            }
        }
        
        let dispatchWorkItem = DispatchWorkItem {
            self.repoTableView.reloadData()
            self.activityIndicator.stopAnimating()
            
            self.saveRepoToCD(repos: self.searchedRepo)
        }
        
        dispatchGroup.notify(queue: .main, work: dispatchWorkItem)
    }
    
    private func saveRepoToCD(repos: [RepoItemCellViewModel]) {
        coreDataManager.saveRepos(repos: repos.map{ $0.repo })
    }
    
    private func fillHomeTab() {
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
        guard let viewModel = viewModel else {
            return
        }
        viewModel.searchByWord = searchedText
        viewModel.paginationNumber = 1
        
        searchedRepo.removeAll()
        repoTableView.reloadData()
        repoTableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        viewModel.searchByWord = searchedText
        coreDataManager.deleteAllCDRepos()
        sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: searchedText)
    }
    
    @IBAction func searchRepoButton(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        performSearchRepositories()
    }
    
    @IBAction func watchedReposButtonTapped(_ sender: Any) {
        let vc = WatchedReposPageVC.instantiateCustom(storyboard: WatchedReposPageVC.storyboardName)
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
        DispatchQueue.global().async {
            guard self.searchedRepo.count - 5 < indexPath.row, let viewModel = self.viewModel else { return }
            self.sequentlyFillingTable(pagination: viewModel.paginationNumber, searchedWord: viewModel.searchByWord)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRepo = self.searchedRepo[indexPath.row]
        guard let selectedRepoUrl = URL(string: selectedRepo.repo.htmlURL ?? "") else { return }
        self.delegate?.repoSelected(vm: selectedRepo,true)
        self.openUrlInSafari(url: selectedRepoUrl)
        self.coreDataManager.updateRepoToWatched(repo: selectedRepo.repo)
        
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
