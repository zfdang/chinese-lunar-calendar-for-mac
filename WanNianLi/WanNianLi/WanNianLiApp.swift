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
    
    var body: some Scene {
        // Menu bar app using MenuBarExtra (macOS 13+)
        MenuBarExtra {
            ContentView()
                .environmentObject(appState)
        } label: {
            StatusBarLabel()
        }
        .menuBarExtraStyle(.window)
        
        // Settings window
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
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

// MARK: - Status Bar Label

/// Menu bar icon with calendar frame and date number
struct StatusBarLabel: View {
    @State private var currentDay: Int = Calendar.current.component(.day, from: Date())
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("calendarIcon")
            .renderingMode(.template)
        Text("\(currentDay)")
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .monospacedDigit()
        .onReceive(timer) { _ in
            currentDay = Calendar.current.component(.day, from: Date())
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
