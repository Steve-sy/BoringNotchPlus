//
//  PomodoroControls.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 2/7/2025.
//

import SwiftUI

struct PomodoroControls: View {
    @ObservedObject var pomodoro = BoringPomodoro.shared
    @EnvironmentObject var vm: BoringViewModel
    @State private var hideWorkItem: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                if vm.showPomodoroInsteadOfCalendar {
                    withAnimation {
                        vm.showPomodoroInsteadOfCalendar = false
                    }
                    // Cancel any scheduled hiding
                    hideWorkItem?.cancel()
                    hideWorkItem = nil
                } else {
                    withAnimation {
                        vm.showPomodoroInsteadOfCalendar = true
                    }

                    // Cancel previous hide if exists
                    hideWorkItem?.cancel()

                    // Schedule new hide
                    let workItem = DispatchWorkItem {
                        withAnimation {
                            vm.showPomodoroInsteadOfCalendar = false
                        }
                        hideWorkItem = nil
                    }

                    hideWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: workItem)
                }
            }) {
                Capsule()
                    .fill(.black)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "timer")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
