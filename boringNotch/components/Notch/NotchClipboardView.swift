//
//  NotchClipboardView.swift
//  boringNotch
//
//  Updated by Mustafa Ramadan on 28/6/2025 & Created by Alessandro Gravagno on 23/04/25.
//

import SwiftUI

struct NotchClipboardView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor

    init(clipboardMonitor: ClipboardMonitor) {
        self.clipboardMonitor = clipboardMonitor
    }

    var body: some View {
        let pinned = clipboardMonitor.data.filter(\.isPinned)
        let unpinned = clipboardMonitor.data.filter { !$0.isPinned }

        if clipboardMonitor.data.isEmpty {
            Text("Clipboard is empty")
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: 148)
                .font(.system(.title3, design: .rounded))

        } else {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 11) {
                    ForEach(pinned + unpinned.reversed(), id: \.self) { item in
                        ClipboardTile(item: item) { toRemove in
                            clipboardMonitor.data.removeAll { $0 == toRemove }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .animation(.easeInOut(duration: 0.25), value: clipboardMonitor.data)
            }
            .scrollIndicators(.never)
        }
    }
}
