//
//  WatchedReposVC.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

class WatchedReposPageVC: UIViewController, StoryboardedProtocol {
    
    static let identifier = "WatchedReposPageVC"
    static let storyboardName = "WatchedReposPage"
    
    @IBOutlet var watchedReposTableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var coreDataManager: CoreMataManagerProtocol?
    
    private var repositarySource = [RepoItemCellViewModel]()
    private var watchedRepos = [RepoItemCellViewModel]()
    private var historyRepos = [RepoItemCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillWatchedRepos()
        fillHistoryRepos()
        tableInitiallyConfiguration()
    }
    
    private func tableInitiallyConfiguration() {
        watchedReposTableView.delegate = self
        watchedReposTableView.dataSource = self
        watchedReposTableView.separatorColor = .clear
        watchedReposTableView.register(RepoTableItemCell.nib(), forCellReuseIdentifier: RepoTableItemCell.cellReuseIdentifier)
        repositarySource = historyRepos
    }
    
    private func fillWatchedRepos() {
        let coreDataManager = coreDataManager ?? CoreDataManager()
        watchedRepos = mapToRepoItemCellViewModels(from: coreDataManager.fetchWatchedRepos())
        guard watchedRepos.count > 20 else { return }
        watchedRepos.removeSubrange(0...watchedRepos.count - 21)
    }
    
    private func fillHistoryRepos() {
        let coreDataManager = coreDataManager ?? CoreDataManager()
        historyRepos = mapToRepoItemCellViewModels(from: coreDataManager.fetchAllCDRepos())
    }
    
    private func mapToRepoItemCellViewModels(from cdRepos: [CDRepos]) -> [RepoItemCellViewModel] {
        let result: [RepoItemCellViewModel]  = cdRepos.map({ cdRepo in
            let repoOwner = RepoOwner(login: cdRepo.ownerName ?? "")
            let repo = RepoItemModel(name: cdRepo.name ?? "", fullName: cdRepo.fullName ?? "", owner: repoOwner, htmlURL: nil, itemDescription: cdRepo.repoDescription, stargazersCount: Int(cdRepo.stars), isSelected: cdRepo.isSelected)
            
            return RepoItemCellViewModel(repo: repo)
        })
        return result
    }
    
    @IBAction func tableSelectorTapped(_ sender: UISegmentedControl) {
        if watchedRepos.count > 20 {
            watchedRepos.removeSubrange(0...watchedRepos.count - 21)
        }
        repositarySource = [historyRepos, watchedRepos][sender.selectedSegmentIndex]
        watchedReposTableView.reloadData()
    }
}

extension WatchedReposPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositarySource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = watchedReposTableView.dequeueReusableCell(withIdentifier: RepoTableItemCell.cellReuseIdentifier, for: indexPath)
        
        if let cell = cell as? RepoTableItemCell {
            let viewModel = repositarySource[indexPath.row]
            cell.setupWith(viewModel: viewModel)
            cell.delegate = self
        }
        
        return cell
    }
}

extension WatchedReposPageVC: RepoItemCellDelegate {
    
    func updateCellHeight(vm: RepoItemCellViewModel?, inBlock: () -> Void) {
        
        if let vm = vm {
            for cellViewModel in repositarySource {
                if cellViewModel === vm {
                    continue
                }

                cellViewModel.expanded = false
            }
        }
        
        inBlock()
        watchedReposTableView.reloadData()
    }
}
