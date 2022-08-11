//
//  RepoItemCellViewModel.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

class RepoItemCellViewModel {
    var repo: RepoItemModel
    var expanded: Bool = false
    var needShowMore: Bool = false
    
    init(repo: RepoItemModel) {
        self.repo = repo
    }
}
