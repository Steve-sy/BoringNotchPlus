//
//  PomodoroControls.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 2/7/2025.
//

import SwiftUI

struct PomodoroControls: View {
    @ObservedObject var pomodoro = BoringPomodoro.shared

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                pomodoro.toggle()
            }) {
                Capsule()
                    .fill(.black)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: pomodoro.isRunning ? "pause.circle.fill" : "timer")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                    }
            }
            .buttonStyle(PlainButtonStyle())

            if pomodoro.isRunning {
                // Show Stop button
                Button(action: {
                    pomodoro.stop()
                }) {
                    Capsule()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "stop.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.medium)
                        }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
//            if pomodoro.wasRunning {
//                Text(pomodoro.timeRemainingFormatted)
//                    .font(.caption.monospacedDigit())
//                    .foregroundColor(.white)
//                    .frame(width: 30, alignment: .center)
//            }
            
        }
    }
}
