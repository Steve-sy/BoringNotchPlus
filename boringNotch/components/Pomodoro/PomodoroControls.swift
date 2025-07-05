//
//  PomodoroControls.swift
//  boringNotch
//
//  Created by Mustafa Ramadan on 2/7/2025.
//

import SwiftUI
import Defaults

struct PomodoroControls: View {
    @ObservedObject var pomodoro = BoringPomodoro.shared
    @EnvironmentObject var vm: BoringViewModel
    @State private var hideWorkItem: DispatchWorkItem?
    
    var body: some View {
        if Defaults[.enablePomodoro] {
            HStack(spacing: 0) {
                Button(action: {
                    if vm.showPomodoroInsteadCalendar {
                        withAnimation {
                            vm.showPomodoroInsteadCalendar = false
                        }
                        // Cancel any scheduled hiding
                        hideWorkItem?.cancel()
                        hideWorkItem = nil
                    } else {
                        withAnimation {
                            vm.showPomodoroInsteadCalendar = true
                        }
                        
                        // Cancel previous hide if exists
                        hideWorkItem?.cancel()
                        
                        // Schedule new hide
                        let workItem = DispatchWorkItem {
                            withAnimation {
                                vm.showPomodoroInsteadCalendar = false
                            }
                            hideWorkItem = nil
                        }
                        
                        hideWorkItem = workItem
                        
                        if Defaults[.autoHidePomodoro] {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 25, execute: workItem)
                        }
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
}
