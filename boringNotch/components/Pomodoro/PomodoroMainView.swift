//
//  PomodoroMainView.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 3/7/2025.
//

import SwiftUI
import Defaults

struct PomodoroMainView: View {
    @ObservedObject var pomodoro = BoringPomodoro.shared
    @State private var blinkOpacity: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
            VStack(spacing: 8) {
                Text("Focus")
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Defaults[.accentColor])
                    .multilineTextAlignment(.center)

                HStack(spacing: 10) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                            .onTapGesture {
                                decrementWork()
                            }
                    

                    Text(pomodoro.timeRemainingFormatted)
                        .font(.system(size: 38, weight: .light, design: .monospaced))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .opacity(pomodoro.isPaused ? blinkOpacity : 1)
                        .onAppear(perform: startBlinking)
                        .onChange(of: pomodoro.isPaused) { startBlinking() }

                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            incrementWork()
                        }
                    
                }

                Text(phaseText)
                    .font(.subheadline)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.gray)

                HStack(spacing: 10) {
                        Text(pomodoro.isPaused ? "Continue" :
                             (pomodoro.isRunning ? "Pause" : "Start Focus →"))
                            .foregroundColor(pomodoro.isPaused ? .green :
                                (pomodoro.isRunning ? .yellow : Defaults[.accentColor]))
                            .font(.subheadline)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .onTapGesture {
                                pomodoro.toggle()
                            }

                    if pomodoro.isRunning || pomodoro.isPaused {
                            Text("Stop")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .onTapGesture {
                                    pomodoro.stop()
                                }
                    }
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Actions
    private func decrementWork() {
        if pomodoro.workMinutes > 1 {
            pomodoro.workMinutes -= 1
            pomodoro.updateTimeRemaining()
        }
    }

    private func incrementWork() {
        if pomodoro.workMinutes < 60 {
            pomodoro.workMinutes += 1
            pomodoro.updateTimeRemaining()
        }
    }

    // MARK: - Helpers
    private var phaseText: String {
        switch pomodoro.currentPhase {
        case .shortBreak: return "in short break!"
        case .longBreak: return "in long break!"
        default: return ""
        }
    }

    private func startBlinking() {
        if pomodoro.isPaused {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                blinkOpacity = 0.3
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                blinkOpacity = 1.0
            }
        }
    }
}
