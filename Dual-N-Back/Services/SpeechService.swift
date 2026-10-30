//
//  SpeechService.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import AVFoundation

/// Handles text-to-speech for letter stimuli and announcements.
@MainActor
final class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
