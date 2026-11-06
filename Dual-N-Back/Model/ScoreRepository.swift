//
//  ScoreRepository.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-31.
//

import Foundation
import CoreData

enum ScoreSortOption {
    case score
    case date
    case name
}
struct ScoreRepository {
    static private let context = PersistenceController.shared.context
    static func saveScore(playerName: String, score: Int, nLevel: Int) {
        let entry = ScoreEntry(context: context)
        entry.playerName = playerName.isEmpty ? "Anonymous" : playerName
        entry.score = Int32(score)
        entry.date = Date()
        entry.nLevel = Int16(nLevel)
        do {
            try context.save()
        } catch {
            print("Failed to save score: \(error.localizedDescription)")
        }
    }
    
    static func fetch(sortedBy option: ScoreSortOption = .score) -> [ScoreEntry] {
        let request: NSFetchRequest<ScoreEntry> = ScoreEntry.fetchRequest()
        switch option {
        case .score:
            request.sortDescriptors = [
                NSSortDescriptor(key: "score", ascending: false),
                NSSortDescriptor(key: "date", ascending: false)
            ]
        case .date:
            request.sortDescriptors = [
                NSSortDescriptor(key: "date", ascending: false)
            ]
        case .name:
            request.sortDescriptors = [
                NSSortDescriptor(key: "playerName", ascending: true, selector:
                                   #selector(NSString.caseInsensitiveCompare(_:)))
            ]
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch scores: \(error.localizedDescription)")
                            return []
        }
        
    }
}
