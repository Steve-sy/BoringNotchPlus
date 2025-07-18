//
//  ClipboardMonitor.swift
//  boringNotch
//
//  Updated by Mustafa Ramadan on 28/6/2025 & Created by Alessandro Gravagno on 28/04/25.
//

import SwiftUI
import AppKit
import Defaults

class ClipboardMonitor: ObservableObject{
    static let shared = ClipboardMonitor()
    
    @Published var data: Array<ClipboardData> = []

    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private static var isInternalCopy = false

    init() {
        if Defaults[.showClipboard] {
            startMonitoring()
        }
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            if ClipboardMonitor.isInternalCopy {
                ClipboardMonitor.isInternalCopy = false
                return
            }

            if let copiedText = pasteboard.string(forType: .string),
               let activeApp = NSWorkspace.shared.frontmostApplication {
                
                let bundleID = activeApp.bundleIdentifier ?? "unknown"
                
                addToClipboard(element: ClipboardData(text: copiedText, bundleID: bundleID))
                
            }
        }
    }
    
    private func addToClipboard(element: ClipboardData) {
        if let existing = data.firstIndex(where: { $0.text == element.text }) {
            data.remove(at: existing)
        }
        data.append(element)
        
        // kick out the oldest non-pinned
        let nonPinnedCount = data.reduce(0) { $0 + ($1.isPinned ? 0 : 1) }
                if nonPinnedCount > 48,
                   let oldest = data.firstIndex(where: { !$0.isPinned }) {
                    data.remove(at: oldest)
                }
    }
    
    static func CopyFromApp(_ text: String){
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        isInternalCopy = true
        pasteboard.setString(text, forType: .string)
    }
    
    func toggleMonitoring(_ enabled: Bool) {
        if enabled {
            startMonitoring()
        } else {
            timer?.invalidate()
            timer = nil
            data.removeAll()
        }
    }
    
    func togglePin(_ item: ClipboardData) {
        if let index = data.firstIndex(of: item) {
            data[index].isPinned.toggle()
            objectWillChange.send()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct ClipboardData: Hashable, Identifiable, Equatable {
    let id = UUID()
    var text: String
    var bundleID: String
    var isPinned: Bool = false

    static func == (lhs: ClipboardData, rhs: ClipboardData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
