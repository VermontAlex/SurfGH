//
//  CoreDataManager.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import CoreData

struct CoreDataManager {
    static var persistentContainerForLocal: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CDRepo")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        let context = CoreDataManager.persistentContainerForLocal.viewContext
        
        return context
    }
    
    func saveRepos(repos: [RepoItemModel]) {
        do {
            try repos.forEach { repo in
                let fetchRequest = NSFetchRequest<CDRepos>(entityName: "CDRepos")
                fetchRequest.predicate = NSPredicate(format: "repoDescription == %@ AND name == %@", repo.itemDescription ?? "", repo.name)
                let countNum = try context.count(for: fetchRequest)
                if countNum == 0 {
                    let cdRepo = CDRepos(context: context)
                    cdRepo.fullName = repo.fullName
                    cdRepo.name = repo.name
                    cdRepo.ownerName = repo.owner.login
                    cdRepo.repoDescription = repo.itemDescription
                    cdRepo.stars = Int64(repo.stargazersCount)
                    cdRepo.isSelected = repo.isSelected
                    do {
                        try context.save()
                    } catch {
                        ErrorHandlerService.errorString("Error for saving object from GetBeacons in CD Manager").handleErrorWithDB()
                    }
                }
            }
        } catch {
            ErrorHandlerService.unknownedError().handleErrorWithDB()
        }
    }
    
    func updateRepoToWatched(repo: RepoItemModel) {
        let fetchRequest = NSFetchRequest<CDRepos>(entityName: "CDRepos")
        fetchRequest.predicate = NSPredicate(format: "repoDescription == %@ AND name == %@",
                                             repo.itemDescription ?? "", repo.name)
        do {
            let repo = try context.fetch(fetchRequest).first
            repo?.isSelected = true
            try context.save()
        } catch {
            ErrorHandlerService.unknownedError().handleErrorWithDB()
        }
    }
    
    func fetchWatchedRepos() -> [CDRepos] {
        let fetchRequest = NSFetchRequest<CDRepos>(entityName: "CDRepos")
        fetchRequest.predicate = NSPredicate(format: "isSelected == %@", NSNumber(true) )
        do {
            return try context.fetch(fetchRequest)
        } catch {
            ErrorHandlerService.unknownedError().handleErrorWithDB()
            return []
        }
    }
    
    func fetchAllCDRepos() -> [CDRepos] {
        let fetchRequest = NSFetchRequest<CDRepos>(entityName: "CDRepos")
        do {
            return try context.fetch(fetchRequest)
        } catch {
            ErrorHandlerService.unknownedError().handleErrorWithDB()
            return []
        }
    }
    
    func deleteAllCDRepos() {
        let fetchRequest = NSFetchRequest<CDRepos>(entityName: "CDRepos")
        do {
            let repos = try context.fetch(fetchRequest)
            repos.forEach({ context.delete($0) })
            try context.save()
        } catch {
            ErrorHandlerService.unknownedError().handleErrorWithDB()
        }
    }
}
