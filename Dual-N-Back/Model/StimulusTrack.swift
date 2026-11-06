//
//  StimulusTrack.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import Foundation

/// Tracks the sequence, current position, responses, and score counts for a single stimulus track (visual or auditory).
struct StimulusTrack {
    let sequence: [Int]
    let n: Int

    private(set) var currentIndex: Int = 0
    private(set) var hasPressedThisEvent: Bool = false
    private(set) var hits: Int = 0
    private(set) var misses: Int = 0
    private(set) var falseTaps: Int = 0

    init(sequence: [Int], n: Int) {
        self.sequence = sequence
        self.n = n
    }

    /// True if the current event matches the event N steps ago.
    var isCurrentEventMatch: Bool {
        guard currentIndex >= n, currentIndex < sequence.count else {return false}
        return sequence[currentIndex] == sequence[currentIndex - n]
    }

    /// Current stimulus value, or nil if track has finished.
    var currentItem: Int? {
        guard currentIndex >= 0 && currentIndex < sequence.count else { return nil }
        return sequence[currentIndex]
    }

    /// Registers a player's match button press, applying guards against early presses and double presses.
    mutating func registerMatchPress() {
        guard currentIndex >= n, currentIndex < sequence.count, !hasPressedThisEvent else {return}
        if (isCurrentEventMatch) {
            hits += 1
        } else {
            falseTaps += 1
        }
        hasPressedThisEvent = true
    }

    /// Advances the track to the next event, recording a miss if an unpressed match is passed.
    mutating func advanceToNextEvent() {
        if !hasPressedThisEvent && isCurrentEventMatch {
            misses += 1
        }
        hasPressedThisEvent = false
        currentIndex += 1
    }
}
