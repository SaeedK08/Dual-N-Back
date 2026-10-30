//
//  GameSettings.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import Foundation

/// Defines which stimulus modality the player wants to train with.
enum StimulusMode: String, CaseIterable, Identifiable, Codable {
    case visual
    case auditory
    case dual

    var id: String { rawValue }
}

/// Stores configuration settings for an N-Back round with default values.
struct GameSettings: Codable, Equatable {
    var stimulusMode: StimulusMode = .dual
    var n: Int = 2
    var eventDuration: TimeInterval = 2.5
    var eventsPerRound: Int = 20
}
