//
//  PersistenceController.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-31.
//

import CoreData

struct PersistenceController {
    /// A single shared instance for the whole app (Singleton pattern).
    static let shared = PersistenceController()

    /// The container that holds the database and sets up the Core Data stack.
    let container: NSPersistentContainer

    /// Convenience accessor to the main-thread context (the in-memory scratchpad).
    var context: NSManagedObjectContext {
        container.viewContext
    }

    private init(inMemory: Bool = false) {
        // Must match the exact name of your ScoreModel.xcdatamodeld file
        container = NSPersistentContainer(name: "ScoreModel")

        // In-memory option: useful for unit tests or SwiftUI previews (writes to RAM, not disk)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Loads the SQLite database file from disk
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }

        // Keeps viewContext automatically synchronized if background threads save changes
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
