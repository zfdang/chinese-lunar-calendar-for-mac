//
//  SettingsView.swift
//  WanNianLi
//
//  Settings window for the app
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var festivalData = FestivalData.shared
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: $appState.launchAtLogin)
            }
            
            Section("Festival Data") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Festival Database")
                        if let date = festivalData.lastUpdateDate {
                            Text("Last updated: \(date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Using default data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Update Now") {
                        Task {
                            await festivalData.updateFromRemote()
                        }
                    }
                    .disabled(festivalData.isLoading)
                }
                
                if festivalData.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Updating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let error = festivalData.updateError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section("Links") {
                Link(destination: URL(string: "https://calendar.zfdang.com")!) {
                    Label("Help & Documentation", systemImage: "questionmark.circle")
                }
                
                Link(destination: URL(string: "https://github.com/zfdang/chinese-lunar-calendar-for-mac")!) {
                    Label("GitHub Repository", systemImage: "link")
                }
                
                Link(destination: URL(string: "mailto:me@zfdang.com?subject=WanNianLi%20Feedback")!) {
                    Label("Contact Author", systemImage: "envelope")
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 380)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
