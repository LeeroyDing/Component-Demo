//
//  TrendingRepoContextImpl.swift
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

import Alamofire
import CoreData

class TrendingRepoContextImpl: TrendingRepoContext {
  private let queue = DispatchQueue.init(label: "TrendingRepo")
  private let sessionManager: SessionManager

  override init() {
    // Zscaler workaround
    // Best software ever
    let policies: [String: ServerTrustPolicy] = [
      "github-trending-api.now.sh": .disableEvaluation
    ]
    sessionManager = SessionManager(
      serverTrustPolicyManager: .init(policies: policies))
    super.init()
  }

  override func fetchTrendingRepos(_ completion: @escaping () -> Void) {
    sessionManager.request("https://github-trending-api.now.sh/repositories")
      .responseJSON(queue: queue, options: []) { (response) in
        sleep(2)
        guard case let .success(json) = response.result,
          let data = json as? [[String: Any]]
          else {
            completion()
            return
        }
        let dtos: [TrendingRepoDTO] = data.enumerated().compactMap {
          guard let author = $1["author"] as? String,
            let desc = $1["description"] as? String,
            let forkCount = $1["forks"] as? Int32,
            let language = $1["language"] as? String?,
            let name = $1["name"] as? String,
            let starCount = $1["stars"] as? Int32,
            let starsToday = $1["currentPeriodStars"] as? Int32
            else { return nil }
          let rank = Int16($0)
          let dto = TrendingRepoDTO()
          dto.author = author
          dto.desc = desc
          dto.forkCount = forkCount
          dto.language = language
          dto.name = name
          dto.rank = rank
          dto.starCount = starCount
          dto.starsToday = starsToday
          return dto
        }
        // Should be injected!
        PersistenceContainer.shared.clearTrendingRepos()
        PersistenceContainer.shared.upsert(trendingRepos: dtos)
        completion()
    }
  }

  override func trendingRepoList() -> NSFetchedResultsController<NSFetchRequestResult> {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrendingRepo")
    fetchRequest.predicate = nil
    fetchRequest.sortDescriptors = [.init(key: "rank", ascending: true)]
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    return frc
  }
}
