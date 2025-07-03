//
//  BoringPomodoro.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 2/7/2025.
//

import Foundation
import Combine
import SwiftUI
import Defaults
import AppKit

enum PomodoroPhase {
    case work, shortBreak, longBreak
}

class BoringPomodoro: ObservableObject {
    static let shared = BoringPomodoro()
    @Default(.pomodoroWorkMinutes) private var workMinutes
    @Default(.pomodoroShortMinutes) private var shortMinutes
    @Default(.pomodoroLongMinutes) private var longMinutes
    @Default(.pomodoroCyclesBeforeLong) private var cyclesBeforeLong
    @Default(.pomodoroSneakInterval) private var sneakInterval
    @Default(.pomodoroSneakDuration) private var sneakDuration
    
    private var workDuration: Int { workMinutes * 60 }
    private var shortBreakDuration: Int { shortMinutes * 60 }
    private var longBreakDuration: Int { longMinutes * 60 }
    private var longBreakAfter: Int { cyclesBeforeLong }
    
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var wasRunning = false
    @Published var currentPhase: PomodoroPhase = .work
    @Published var shouldShowSneakPeek = false
    @Published private(set) var timeRemaining: Int = 0
    @Published var didCompleteCycle = false
    
    private var timer: AnyCancellable?
    private var sneakTimer: Timer?
    private var cycleCount = 0
    
    init() {
        // start with your configured work duration
        self.timeRemaining = workDuration
    }
    
    var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var currentPhaseLabel: String {
        if didCompleteCycle {
            return "You did it! 🎉"
        }
        
        switch currentPhase {
        case .work: return "Focus Time! Let's Work 💪"
        case .shortBreak: return "Take a Short Break 🌿"
        case .longBreak: return "Take It Easy! Long Break ☕"
        }
    }

    func toggle() {
        if !isRunning {
            isRunning = true
            isPaused = false
            wasRunning = true
            startTimer()
            startSneakCycle()
            showSneakPeekTemporarily()
        } else {
            isPaused.toggle()
            isPaused ? timer?.cancel() : startTimer()
        }
    }

    func stop() {
        timer?.cancel()
        isRunning = false
        isPaused = false
        wasRunning = false
        currentPhase = .work
        cycleCount = 0
        timeRemaining = workDuration
        didCompleteCycle = false
        stopSneakCycle()
        withAnimation(.bouncy) {
            shouldShowSneakPeek = false
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.cancel()
                    self.isRunning = false
                    self.isPaused = false
                    self.wasRunning = false
                    self.stopSneakCycle()
                    withAnimation(.bouncy) {
                        self.shouldShowSneakPeek = false
                    }
                    self.advancePhase()
                }
            }
    }
    
//    private func advancePhase() {
//        switch currentPhase {
//        case .work:
//            cycleCount += 1
//            switch cycleCount {
//            case 1, 2:
//                currentPhase = .shortBreak
//            case 3:
//                currentPhase = .longBreak
//            case 4:
//                celebrateCompletion()
//                return
//            default:
//                currentPhase = .shortBreak
//            }
//
//        case .shortBreak, .longBreak:
//            currentPhase = .work
//        }
//
//        timeRemaining = phaseDuration(currentPhase)
//
//        isRunning = true
//        wasRunning = true
//        startTimer()
//        startSneakCycle()
//        showSneakPeekTemporarily()
//        playSound(for: currentPhase)
//    }
    
    private func advancePhase() {
        switch currentPhase {
        case .work:
            cycleCount += 1

            if cycleCount == longBreakAfter {
                currentPhase = .longBreak
            } else if cycleCount > longBreakAfter {
                celebrateCompletion()
                return
            } else {
                currentPhase = .shortBreak
            }

        case .shortBreak, .longBreak:
            currentPhase = .work
        }

        timeRemaining = phaseDuration(currentPhase)
        isRunning = true
        wasRunning = true
        startTimer()
        startSneakCycle()
        showSneakPeekTemporarily()
        playSound(for: currentPhase)
    }
    
    private func phaseDuration(_ phase: PomodoroPhase) -> Int {
        switch phase {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    private func startSneakCycle() {
        sneakTimer?.invalidate()
        sneakTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            DispatchQueue.main.async {
                self.showSneakPeekTemporarily()
            }
        }
    }

    private func stopSneakCycle() {
        sneakTimer?.invalidate()
        withAnimation(.bouncy) {
            self.shouldShowSneakPeek = false
        }
    }

    private func showSneakPeekTemporarily() {
//        // Local SneakPeek (for inline HUD)
//        DispatchQueue.main.async {
//            withAnimation(.bouncy) {
//                self.shouldShowSneakPeek = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                withAnimation(.bouncy) {
//                    self.shouldShowSneakPeek = false
//                }
//            }
//        }

        // Global SneakPeek (below music)
        DispatchQueue.main.async {
            withAnimation(.bouncy) {
                BoringViewCoordinator.shared.toggleSneakPeek(
                    status: true,
                    type: .pomodoro,
                    duration: 5.0,
                    value: 0,
                    icon: "timer"
                )
            }
        }
    }
    
    private func celebrateCompletion() {
        stopSneakCycle()
        stop()
        didCompleteCycle = true

        NSSound(named: .init("Hero"))?.play()

        DispatchQueue.main.async {
            BoringViewCoordinator.shared.toggleSneakPeek(
                status: true,
                type: .pomodoro,
                duration: 6.0,
                value: 0,
                icon: "checkmark.seal"
            )
        }

    }
    
    private func playSound(for phase: PomodoroPhase) {
      let name: NSSound.Name
      switch phase {
        case .work:       name = NSSound.Name("Glass")             // simple system beep
        case .shortBreak: name = NSSound.Name("Funk")   // “Ping”
        case .longBreak:  name = NSSound.Name("Submarine") // “Submarine”
      }
      NSSound(named: name)?.play()
    }
    
}
