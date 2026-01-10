//
//  WanNianLiApp.swift
//  WanNianLi
//
//  Pure Swift menu bar calendar app
//

import SwiftUI
import ServiceManagement

@main
struct WanNianLiApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var statusBarManager = StatusBarManager()
    
    var body: some Scene {
        // Menu bar app using MenuBarExtra (macOS 13+)
        MenuBarExtra {
            ContentView()
                .environmentObject(appState)
        } label: {
            Image(nsImage: statusBarManager.statusBarImage)
        }
        .menuBarExtraStyle(.window)
        
        // Settings window
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Status Bar Manager

/// Manages the status bar icon with date overlay
class StatusBarManager: ObservableObject {
    @Published var statusBarImage: NSImage
    
    private var timer: Timer?
    private var currentDay: Int = 0
    
    init() {
        statusBarImage = NSImage()
        updateIcon()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateIcon()
        }
    }
    
    func updateIcon() {
        let newDay = Calendar.current.component(.day, from: Date())
        if newDay != currentDay {
            currentDay = newDay
            statusBarImage = createStatusBarImage(day: currentDay)
        }
    }
    
    private func createStatusBarImage(day: Int) -> NSImage {
        // Load base calendar icon
        guard let baseImage = NSImage(named: "calendarIcon") else {
            return NSImage()
        }
        
        // Create a larger image for better visibility
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size, flipped: false) { rect in
            // Draw base icon (it should already have the calendar frame)
            baseImage.draw(in: rect)
            
            // Draw day number in black, positioned in calendar body (below the hooks)
            let dayString = String(format: "%02d", day)
            let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.black
            ]
            
            // Position text in the calendar body area (lower part of icon)
            let textSize = dayString.size(withAttributes: attributes)
            let textRect = NSRect(
                x: (rect.width - textSize.width) / 2,
                y: 1,  // Lower position to center in white area
                width: textSize.width,
                height: textSize.height
            )
            
            dayString.draw(in: textRect, withAttributes: attributes)
            
            return true
        }
        
        // Don't use template mode - we want our custom colors
        image.isTemplate = false
        return image
    }
}

// MARK: - App State

/// Shared app state
class AppState: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var displayYear: Int
    @Published var displayMonth: Int
    
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
        }
    }
    
    init() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        self.displayYear = components.year!
        self.displayMonth = components.month!
    }
    
    func goToToday() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        displayYear = components.year!
        displayMonth = components.month!
        selectedDate = today
    }
    
    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }
}

// MARK: - Content View

/// Main content view shown in popover
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView()
                .environmentObject(appState)
            
            Divider()
            
            // Bottom toolbar
            HStack {
                Button(action: { NSApp.terminate(nil) }) {
                    Label("Quit", systemImage: "power")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: openSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help("Settings")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 340, height: 460)
    }
    
    private func openSettings() {
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
