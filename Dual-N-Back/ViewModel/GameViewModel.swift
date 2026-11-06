//
//  GameViewModel.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import Foundation
import Combine

enum GamePhase {
    case idle
    case running
    case finished
}

/// Visual button feedback states for user interactions.
enum ButtonFeedback: Equatable {
    case none
    case hit       // green
    case falseTap  // yellow
    case miss      // red
}

/// Main view model coordinating the Dual N-Back game state, timer, and user interactions.
@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var phase: GamePhase = .idle
    @Published var settings = GameSettings.load() {
        didSet {
            settings.save()
        }
    }
    
    @Published var scoreHistory: [ScoreEntry] = []
    init() {
        loadScoreHistory()
    }
    
    //Tracks current stimulus
    @Published private(set) var currentVisualItem: Int? = nil
    @Published private(set) var currentAudioItem: Int? = nil
    
    // Button visual feedback states
    @Published private(set) var visualFeedback: ButtonFeedback = .none
    @Published private(set) var audioFeedback: ButtonFeedback = .none
    
    //Live HUD stats
    @Published private(set) var currentEventNumber : Int = 0
    @Published private(set) var correctResponses: Int = 0
    
    // End of round stats
    @Published private(set) var finalScore: Int = 0
    @Published private(set) var finalPercentage: Double = 0
    @Published private(set) var hits: Int = 0
    @Published private(set) var misses: Int = 0
    @Published private(set) var falseTaps: Int = 0
    @Published private(set) var highestScore: Int = 0
    
    // Depencencies from Model & Service
    private let scoreCalculator = ScoreCalculator()
    private let sequenceGenerator = SequenceGenerator()
    private let speechService = SpeechService()
    var isVoiceAvailable: Bool {
        speechService.isVoiceAvailable
    }
    private var visualTrack: StimulusTrack?
    private var audioTrack: StimulusTrack?
    
    // Cancable timer
    private var roundTask: Task<Void, Never>?
    
    // Phonetically distinct letters
    let letters: [String] = ["c", "h", "k", "l", "q", "r", "s", "t"]
    
    func startRound() {
        roundTask?.cancel()
        currentVisualItem = nil
        currentAudioItem = nil
        visualFeedback = .none
        audioFeedback = .none
        currentEventNumber = 0
        correctResponses = 0
        finalScore = 0
        finalPercentage = 0
        hits = 0
        misses = 0
        falseTaps = 0
        visualTrack = nil
        audioTrack = nil
        let n = settings.n
        let length = settings.eventsPerRound
        switch settings.stimulusMode {
        case .visual:
            let visualSequence = sequenceGenerator.generate(length: length, n: n, itemCount: settings.gridSize * settings.gridSize, matchRate: 0.3)
            visualTrack = StimulusTrack(sequence: visualSequence, n: n)
        case .auditory:
            let audioSequence = sequenceGenerator.generate(length: length, n: n, itemCount: settings.letterCount, matchRate: 0.3)
            audioTrack = StimulusTrack(sequence: audioSequence, n: n)
        case .dual:
            let visualSequence = sequenceGenerator.generate(length: length, n: n, itemCount: settings.gridSize * settings.gridSize, matchRate: 0.3)
            visualTrack = StimulusTrack(sequence: visualSequence, n: n)
            let audioSequence = sequenceGenerator.generate(length: length, n: n, itemCount: settings.letterCount, matchRate: 0.3)
            audioTrack = StimulusTrack(sequence: audioSequence, n: n)
        }
        phase = .running
        roundTask = Task {await runRoundLoop()}
    }
    
    
    /// How long the cell stays lit within one event.
    //private var stimulusOnTime: Double { min(0.5, settings.eventDuration / 2) }
    public var stimulusOnTime: Double {settings.eventDuration / 2}
    func runRoundLoop() async {
        for _ in 0..<settings.eventsPerRound {
            guard !Task.isCancelled else { return }
            currentEventNumber += 1
            currentVisualItem = visualTrack?.currentItem
            
            if let audioIndex = audioTrack?.currentItem {
                currentAudioItem = audioIndex
                if (isVoiceAvailable) {
                    speechService.speak(letters[audioIndex])
                }
                
            }
            
            try? await Task.sleep(for: .seconds(stimulusOnTime))
            guard !Task.isCancelled else { return }
            currentVisualItem = nil
            
            try? await Task.sleep(for: .seconds(settings.eventDuration - stimulusOnTime))
            guard !Task.isCancelled else { return }
            
            // Check for unpressed matches before advancing (Miss feedback)
            if visualTrack?.isCurrentEventMatch == true && visualTrack?.hasPressedThisEvent == false {
                triggerVisualFeedback(.miss)
            }
            if audioTrack?.isCurrentEventMatch == true && audioTrack?.hasPressedThisEvent == false {
                triggerAudioFeedback(.miss)
            }
            
            visualTrack?.advanceToNextEvent()
            audioTrack?.advanceToNextEvent()
        }
        finishRound()
    }
    
    func registerVisualMatch() {
        guard phase == .running else { return }
        let isMatch = visualTrack?.isCurrentEventMatch ?? false
        visualTrack?.registerMatchPress()
        updateLiveHUD()
        triggerVisualFeedback(isMatch ? .hit : .falseTap)
    }
    
    func registerAudioMatch() {
        guard phase == .running else { return }
        let isMatch = audioTrack?.isCurrentEventMatch ?? false
        audioTrack?.registerMatchPress()
        updateLiveHUD()
        triggerAudioFeedback(isMatch ? .hit : .falseTap)
    }
    
    private func triggerVisualFeedback(_ feedback: ButtonFeedback) {
        visualFeedback = feedback
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            if visualFeedback == feedback {
                visualFeedback = .none
            }
        }
    }
    
    private func triggerAudioFeedback(_ feedback: ButtonFeedback) {
        audioFeedback = feedback
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            if audioFeedback == feedback {
                audioFeedback = .none
            }
        }
    }
    
    func updateLiveHUD() {
        correctResponses = (visualTrack?.hits ?? 0) + (audioTrack?.hits ?? 0)
    }
    
    func finishRound() {
        currentVisualItem = nil
        currentAudioItem = nil
        
        hits = (visualTrack?.hits ?? 0) + (audioTrack?.hits ?? 0)
        misses = (visualTrack?.misses ?? 0) + (audioTrack?.misses ?? 0)
        falseTaps = (visualTrack?.falseTaps ?? 0) + (audioTrack?.falseTaps ?? 0)
        
        let result = scoreCalculator.calculateScore(hits: hits, misses: misses, falseTaps: falseTaps)
        finalScore = result.score
        finalPercentage = result.scorePercentage
        
        if finalScore > highestScore {
            highestScore = finalScore
        }
        
        phase = .finished
    }
    
    func cancelRound() {
        roundTask?.cancel()
        currentVisualItem = nil
        currentAudioItem = nil
        visualFeedback = .none
        audioFeedback = .none
        phase = .idle
    }
    
    func loadScoreHistory(orderBy option: ScoreSortOption = .score) {
        scoreHistory = ScoreRepository.fetch(sortedBy: option)
        highestScore = scoreHistory.map { Int($0.score) }.max() ?? 0
    }
    
    func saveCurrentScore(playerName: String) {
        ScoreRepository.saveScore(playerName: playerName, score: finalScore, nLevel: settings.n)
        loadScoreHistory()
    }
}
