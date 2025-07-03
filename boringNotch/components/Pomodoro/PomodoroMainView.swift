//
//  PomodoroMainView.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 3/7/2025.
//

import SwiftUI

struct PomodoroMainView: View {
    @ObservedObject var pomodoro = BoringPomodoro.shared

    var body: some View {
        VStack(spacing: 10) {
            Text("Focus")
                .font(.headline)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)

            Text(pomodoro.timeRemainingFormatted)
                .font(.system(size: 40, weight: .light, design: .monospaced))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                Text(pomodoro.isPaused ? "Continue" : (pomodoro.isRunning ? "Pause" : "Start Focus →"))
                    .foregroundColor(pomodoro.isPaused ? .green : (pomodoro.isRunning ? .yellow : .blue))
                    .font(.subheadline)
                    .onTapGesture {
                        pomodoro.toggle()
                    }

                if pomodoro.isRunning || pomodoro.isPaused {
                        Text("Stop")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .onTapGesture {
                                pomodoro.stop()
                            }

                }
            }
        }
        .padding()
        .frame(width: 180)
    }
}
