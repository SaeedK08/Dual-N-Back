//
//  SequenceGenerator.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import Foundation

/// Generates sequences of stimuli for N-Back rounds, ensuring first-n guarantees and target match rates.
struct SequenceGenerator {
    /// Generates a sequence of stimulus indices using an injected random number generator.
    func generate<R: RandomNumberGenerator>(
        length: Int,
        n: Int,
        itemCount: Int,
        matchRate: Double,
        using rng: inout R
    ) -> [Int] {
        guard length > 0, n > 0, itemCount >= 2 else {return []}
        var sequence: [Int] = Array(repeating: -1, count: length)
        for i in 0..<length {
            if (i < n) {
                sequence[i] = Int.random(in: 0..<itemCount, using: &rng)
            }
            else {
                let roll = Double.random(in: 0...1, using: &rng)
                if (roll < matchRate) {                 // < matchRate to guarantee that 0.0 < 0.0 will not math
                    sequence[i] = sequence[i-n]
                } else {
                    var randItem: Int
                    repeat {
                        randItem = Int.random(in: 0..<itemCount, using: &rng)
                    } while(randItem == sequence[i-n])
                    sequence[i] = randItem
                }
            }
        }
        
        return sequence
    }

    /// Convenience overload using the system random number generator.
    func generate(
        length: Int,
        n: Int,
        itemCount: Int,
        matchRate: Double
    ) -> [Int] {
        var systemRNG = SystemRandomNumberGenerator()
        return generate(length: length, n: n, itemCount: itemCount, matchRate: matchRate, using: &systemRNG)
    }
}
