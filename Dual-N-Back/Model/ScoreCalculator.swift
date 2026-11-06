//
//  ScoreCalculator.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import Foundation

/// Calculates player scores and accuracy metrics from hit, miss, and false alarm tallies.
struct ScoreCalculator {
    let hitWeight = 2
    let falseTapWeight = 2
    let missWeight = 1
    
    func calculateScore(
        hits: Int,
        misses: Int,
        falseTaps: Int)
    -> (score: Int, scorePercentage: Double) {
        let weightedPoints = (hits * hitWeight) - (misses * missWeight) - (falseTaps * falseTapWeight)
        let maxPossiblePoints = (misses + hits) * hitWeight
        if maxPossiblePoints <= 0 {
            return (0, 0.0)
        } else {
            let scorePercentage: Double = (Double(weightedPoints) / Double(maxPossiblePoints)) * 100.0
            return(max(0, weightedPoints), max(0.0, round(scorePercentage)))
        }
    }
    
}
