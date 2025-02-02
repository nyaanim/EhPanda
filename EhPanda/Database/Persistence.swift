//
//  Persistence.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/07/04.
//

import CoreData
import SwiftyBeaver

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Model")

        container.loadPersistentStores {
            if let error = $1 {
                SwiftyBeaver.error(error as Any)
            }
        }
        return container
    }()

    static func prepareForPreviews() {
        PersistenceController.add(galleries: [Gallery.preview])
        PersistenceController.add(detail: GalleryDetail.preview)
        PersistenceController.update(fetchedState: GalleryState.preview)
    }
    static func saveContext() {
        let context = shared.container.viewContext
        dispatchMainSync {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    SwiftyBeaver.error(error)
                    fatalError("Unresolved error \(error)")
                }
            }
        }
    }

    static func checkExistence<MO: NSManagedObject>(
        entityType: MO.Type, predicate: NSPredicate
    ) -> Bool {
        fetch(entityType: entityType, predicate: predicate) != nil
    }

    static func materializedObjects(
        in context: NSManagedObjectContext,
        matching predicate: NSPredicate
    ) -> [NSManagedObject] {
        var objects = [NSManagedObject]()
        for object in context.registeredObjects
        where !object.isFault {
            guard object.entity.attributesByName
                    .keys.contains("gid"),
                  predicate.evaluate(with: object)
            else { continue }
            objects.append(object)
        }
        return objects
    }

    static func fetch<MO: NSManagedObject>(
        entityType: MO.Type, predicate: NSPredicate? = nil,
        findBeforeFetch: Bool = true, commitChanges: ((MO?) -> Void)? = nil
    ) -> MO? {
        let managedObject = fetch(
            entityType: entityType, fetchLimit: 1,
            predicate: predicate, findBeforeFetch: findBeforeFetch
        ).first
        commitChanges?(managedObject)
        return managedObject
    }

    static func fetch<MO: NSManagedObject>(
        entityType: MO.Type,
        fetchLimit: Int = 0,
        predicate: NSPredicate? = nil,
        findBeforeFetch: Bool = true,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [MO] {
        var results = [MO]()
        let context = shared.container.viewContext
        dispatchMainSync {
            if findBeforeFetch, let predicate = predicate {
                if let objects = materializedObjects(
                    in: context, matching: predicate
                ) as? [MO], !objects.isEmpty {
                    results = objects
                    return
                }
            }
            let request = NSFetchRequest<MO>(
                entityName: String(describing: entityType)
            )
            request.predicate = predicate
            request.fetchLimit = fetchLimit
            request.sortDescriptors = sortDescriptors
            results = (try? context.fetch(request)) ?? []
        }
        return results
    }

    static func fetchOrCreate<MO: NSManagedObject>(
        entityType: MO.Type, predicate: NSPredicate? = nil,
        commitChanges: ((MO?) -> Void)? = nil
    ) -> MO {
        if let storedMO = fetch(
            entityType: entityType,
            predicate: predicate,
            commitChanges: commitChanges
        ) {
            return storedMO
        } else {
            let newMO = MO(
                context: shared
                    .container
                    .viewContext
            )
            commitChanges?(newMO)
            saveContext()
            return newMO
        }
    }

    static func update<MO: NSManagedObject>(
        entityType: MO.Type,
        predicate: NSPredicate? = nil,
        createIfNil: Bool = false,
        commitChanges: ((MO) -> Void)
    ) {
        let storedMO: MO?
        if createIfNil {
            storedMO = fetchOrCreate(
                entityType: entityType,
                predicate: predicate
            )
        } else {
            storedMO = fetch(
                entityType: entityType,
                predicate: predicate
            )
        }
        if let storedMO = storedMO {
            commitChanges(storedMO)
            saveContext()
        }
    }

    static func update<MO: GalleryIdentifiable>(
        entityType: MO.Type, gid: String,
        createIfNil: Bool = false,
        commitChanges: @escaping ((MO) -> Void)
    ) {
        dispatchMainSync {
            let storedMO: MO?
            if createIfNil {
                storedMO = fetchOrCreate(
                    entityType: entityType, gid: gid
                )
            } else {
                storedMO = fetch(
                    entityType: entityType, gid: gid
                )
            }
            if let storedMO = storedMO {
                commitChanges(storedMO)
                saveContext()
            }
        }
    }
}

// MARK: Protocol Definition
protocol ManagedObjectProtocol {
    associatedtype Entity
    func toEntity() -> Entity
}

protocol ManagedObjectConvertible {
    associatedtype ManagedObject: NSManagedObject, ManagedObjectProtocol

    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject
}

protocol GalleryIdentifiable: NSManagedObject {
    var gid: String { get set }
}
