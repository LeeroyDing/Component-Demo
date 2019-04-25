//
//  PersistenceContainer.swift
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

import CoreData

class PersistenceContainer {
  private let container = NSPersistentContainer(name: "GitHub")

  public static let shared: PersistenceContainer = .init()

  public var viewContext: NSManagedObjectContext {
    return container.viewContext
  }

  private init() {
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description];
    container.loadPersistentStores { _, _  in }
    container.viewContext.automaticallyMergesChangesFromParent = true
  }

  func clearRepositories() {
    let context = container.newBackgroundContext()
    context.performAndWait {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Repository")
      fetchRequest.predicate = nil
      fetchRequest.sortDescriptors = [.init(key: "id", ascending: true)];  // doesn't matter
      for obj in try! context.fetch(fetchRequest) {
        context.delete(obj)
      }
      try! context.save()
    }
  }

  func upsert(repositories: [RepositoryDTO]) {
    let context = container.newBackgroundContext()
    context.performAndWait {
      context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      for dto in repositories {
        let entity = Repository(context: context)
        entity.id = dto.id
        entity.name = dto.name
        entity.pushedAt = dto.pushedAt
      }
      try! context.save()
    }
  }
}

extension Repository {
  func toDTO() -> RepositoryDTO {
    let dto = RepositoryDTO()
    dto.id = id
    dto.name = name!
    dto.pushedAt = pushedAt!
    return dto
  }
}
