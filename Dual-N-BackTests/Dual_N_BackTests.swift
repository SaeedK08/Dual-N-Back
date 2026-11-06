//
//  Dual_N_BackTests.swift
//  Dual-N-BackTests
//
//  Created by Saeed Kassab on 2026-10-30.
//

import XCTest
@testable import Dual_N_Back

/// A simple, deterministic pseudo-random number generator for reproducible tests.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

final class Dual_N_BackTests: XCTestCase {

    let generator = SequenceGenerator()

    // MARK: - SequenceGenerator Tests

    /// Tests that the generated sequence has the exact requested length and valid indices.
    func testSequenceLengthMatchesRequested() {
        let length = 20
        let itemCount = 9
        let sequence = generator.generate(length: length, n: 2, itemCount: itemCount, matchRate: 0.3)

        XCTAssertEqual(sequence.count, length, "Sequence length must match the requested length")
        for item in sequence {
            XCTAssertTrue(item >= 0 && item < itemCount, "Each item must be a valid index in 0..<\(itemCount)")
        }
    }

    /// Boundary test: 0.0 match rate must produce ZERO matches.
    func testZeroMatchRateProducesNoMatches() {
        let n = 2
        var rng = SeededRandomNumberGenerator(seed: 12345)
        let sequence = generator.generate(length: 30, n: n, itemCount: 9, matchRate: 0.0, using: &rng)

        for i in n..<sequence.count {
            XCTAssertNotEqual(sequence[i], sequence[i - n], "With 0.0 match rate, event at \(i) must NOT match event at \(i - n)")
        }
    }

    /// Boundary test: 1.0 match rate must produce 100% matches for all events after the first N.
    func testFullMatchRateProducesAllMatches() {
        let n = 2
        var rng = SeededRandomNumberGenerator(seed: 12345)
        let sequence = generator.generate(length: 30, n: n, itemCount: 9, matchRate: 1.0, using: &rng)

        for i in n..<sequence.count {
            XCTAssertEqual(sequence[i], sequence[i - n], "With 1.0 match rate, event at \(i) MUST match event at \(i - n)")
        }
    }

    /// Tests Requirement B-08: Target match rate is between 20% and 40% across rounds.
    func testTargetMatchRateEnforced() {
        let n = 2
        let length = 20
        let rounds = 50
        var rng = SeededRandomNumberGenerator(seed: 999)

        var totalOpportunities = 0
        var totalMatches = 0

        for _ in 0..<rounds {
            let sequence = generator.generate(length: length, n: n, itemCount: 9, matchRate: 0.3, using: &rng)
            for i in n..<sequence.count {
                totalOpportunities += 1
                if sequence[i] == sequence[i - n] {
                    totalMatches += 1
                }
            }
        }

        let actualRate = Double(totalMatches) / Double(totalOpportunities)
        XCTAssertGreaterThanOrEqual(actualRate, 0.20, "Actual match rate (\(actualRate)) must be at least 20%")
        XCTAssertLessThanOrEqual(actualRate, 0.40, "Actual match rate (\(actualRate)) must be at most 40%")
    }

    // MARK: - ScoreCalculator Tests

    let scoreCalculator = ScoreCalculator()

    /// Tests that a perfect round calculates score with full hit points and 100% accuracy.
    func testScoreCalculationWithPerfectRound() {
        // 5 hits * 2 = 10, 0 misses, 0 false taps
        let result = scoreCalculator.calculateScore(hits: 5, misses: 0, falseTaps: 0)
        XCTAssertEqual(result.score, 10)
        XCTAssertEqual(result.scorePercentage, 100.0)
    }

    /// Tests Requirement B-09 & Q11: Score and percentage must never drop below zero.
    func testScoreNeverDropsBelowZero() {
        // 0 hits, 5 misses (-5), 5 false taps (-10) = raw -15, but must clamp to 0
        let result = scoreCalculator.calculateScore(hits: 0, misses: 5, falseTaps: 5)
        XCTAssertEqual(result.score, 0, "Score must never be negative")
        XCTAssertEqual(result.scorePercentage, 0.0, "Score percentage must never be negative")
    }

    /// Tests Q11: Spamming the match button yields zero score and zero percentage.
    func testSpammingYieldsZeroScore() {
        // 4 hits (+8), 4 false taps (-8), 0 misses = 0
        let result = scoreCalculator.calculateScore(hits: 4, misses: 0, falseTaps: 4)
        XCTAssertEqual(result.score, 0, "Spamming match button must yield zero score")
        XCTAssertEqual(result.scorePercentage, 0.0, "Spamming match button must yield zero percentage")
    }

    /// Tests that zero total matches returns safe zero without crashing (division by zero guard).
    func testZeroMatchesReturnsZeroWithoutCrashing() {
        let result = scoreCalculator.calculateScore(hits: 0, misses: 0, falseTaps: 0)
        XCTAssertEqual(result.score, 0)
        XCTAssertEqual(result.scorePercentage, 0.0)
    }

    // MARK: - StimulusTrack Tests

    /// Tests Requirement D-07 & Q3 & Q8: Match press is ignored during the first N events.
    func testMatchPressIgnoredDuringFirstNEvents() {
        var track = StimulusTrack(sequence: [1, 2, 1, 2], n: 2)
        XCTAssertEqual(track.currentIndex, 0)

        // Event 0 (before N=2): press must be ignored
        track.registerMatchPress()
        XCTAssertEqual(track.hits, 0)
        XCTAssertEqual(track.falseTaps, 0)

        // Event 1 (before N=2): press must be ignored
        track.advanceToNextEvent()
        XCTAssertEqual(track.currentIndex, 1)
        track.registerMatchPress()
        XCTAssertEqual(track.hits, 0)
        XCTAssertEqual(track.falseTaps, 0)
    }

    /// Tests Requirement D-08 & Q9 & Q28: Multiple presses on the same event are ignored after the first.
    func testDoublePressOnSameEventIsIgnored() {
        var track = StimulusTrack(sequence: [3, 7, 3], n: 2)
        // Advance to event 2 (which is a match with event 0: 3 == 3)
        track.advanceToNextEvent() // index 1
        track.advanceToNextEvent() // index 2

        XCTAssertEqual(track.currentIndex, 2)
        XCTAssertTrue(track.isCurrentEventMatch)

        // First press: registers a hit
        track.registerMatchPress()
        XCTAssertEqual(track.hits, 1)
        XCTAssertEqual(track.falseTaps, 0)

        // Second press on the exact same event: must be completely ignored
        track.registerMatchPress()
        XCTAssertEqual(track.hits, 1, "Second press on same event must not increment hits")
        XCTAssertEqual(track.falseTaps, 0, "Second press on same event must not be counted as false tap")
    }

    /// Tests Requirement D-05: Correct match press increments hits.
    func testCorrectMatchIncrementsHits() {
        var track = StimulusTrack(sequence: [4, 9, 4], n: 2)
        track.advanceToNextEvent() // 1
        track.advanceToNextEvent() // 2 (match: 4 == 4)

        track.registerMatchPress()
        XCTAssertEqual(track.hits, 1)
        XCTAssertEqual(track.falseTaps, 0)
    }

    /// Tests Requirement D-05: Incorrect match press increments false taps.
    func testIncorrectMatchIncrementsFalseTaps() {
        var track = StimulusTrack(sequence: [4, 9, 2], n: 2)
        track.advanceToNextEvent() // 1
        track.advanceToNextEvent() // 2 (non-match: 2 != 4)

        track.registerMatchPress()
        XCTAssertEqual(track.hits, 0)
        XCTAssertEqual(track.falseTaps, 1)
    }

    /// Tests Requirement D-05 & Q10: Unpressed match increments misses when advancing to next event.
    func testUnpressedMatchIncrementsMissesOnAdvance() {
        var track = StimulusTrack(sequence: [4, 9, 4, 1], n: 2)
        track.advanceToNextEvent() // 1
        track.advanceToNextEvent() // 2 (match: 4 == 4)

        // Player does NOT press match for event 2
        XCTAssertEqual(track.hits, 0)
        XCTAssertEqual(track.misses, 0)

        // Advance to next event: should now detect the missed match
        track.advanceToNextEvent() // 3
        XCTAssertEqual(track.misses, 1, "Advancing past an unpressed match must record a miss")
    }
}
