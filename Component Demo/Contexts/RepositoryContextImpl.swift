//
//  RepositoryContextImpl.swift
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

import Alamofire
import CoreData

class RepositoryContextImpl: RepositoryContext {
  private let queue = DispatchQueue.init(label: "Repository")
  private let dateFormatter = ISO8601DateFormatter()

  override func fetchRepositories(_ completion: @escaping () -> Void) {
    debugPrint("Start fetching")
    request("https://api.github.com/users/github/repos?sort=pushed&direction=desc")
      .responseJSON(queue: queue, options: []) { [dateFormatter](response) in
        debugPrint("Start parsing")
        guard case let .success(json) = response.result,
          let data = json as? [[String: Any]]
          else { fatalError() }
        let dtos: [RepositoryDTO] = data.compactMap {
          guard let id = $0["id"] as? Int64,
            let name = $0["name"] as? String,
            let pushedAtString = $0["pushed_at"] as? String,
            let pushedAt = dateFormatter.date(from: pushedAtString)
            else { return nil }
          let dto = RepositoryDTO()
          dto.id = id
          dto.name = name
          dto.pushedAt = pushedAt
          return dto
        }
        debugPrint("Start saving...")
        // Should be injected!
        PersistenceContainer.shared.clearRepositories()
        PersistenceContainer.shared.upsert(repositories: dtos)
        debugPrint("finished")
        completion()
    }
  }

  override func repositoriesList() -> NSFetchedResultsController<NSFetchRequestResult> {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Repository")
    fetchRequest.predicate = nil
    fetchRequest.sortDescriptors = [.init(key: "pushedAt", ascending: false)]
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    return frc
  }
}
