import AppKit
import LunarCore
import ServiceManagement
import SwiftUI

/// 外观：跟随系统 / 日间模式 / 夜间模式
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "日间模式"
        case .dark: return "夜间模式"
        }
    }

    private static let key = "appearance"
    static let didChange = Notification.Name("WanNianLiAppearanceDidChange")

    static var saved: AppearanceMode {
        UserDefaults.standard.string(forKey: key).flatMap(AppearanceMode.init) ?? .system
    }

    @MainActor
    func apply() {
        UserDefaults.standard.set(rawValue, forKey: Self.key)
        switch self {
        case .system: NSApp.appearance = nil
        case .light: NSApp.appearance = NSAppearance(named: .aqua)
        case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
        }
        NotificationCenter.default.post(name: Self.didChange, object: nil)
    }
}

/// 日历左下角的设置菜单
@MainActor
final class AppMenu: ObservableObject {
    static let helpURL = URL(string: "https://calendar.zfdang.com")!
    static let changelogURL = URL(string: "https://github.com/zfdang/chinese-lunar-calendar-for-mac/blob/master/CHANGELOG.md")!
    static let contactURL = URL(string: "mailto:me@zfdang.com?subject=About%20Chinese%20Lunar%20Calendar%20for%20MAC")!

    /// 选择"更新假日信息"时调用
    var onUpdateHolidays: () -> Void = {}
    /// 选择"自定义日期"时调用
    var onEditCustomEvents: () -> Void = {}

    @Published private(set) var launchAtLogin = AppMenu.isLoginItemEnabled
    @Published var appearance = AppearanceMode.saved {
        didSet { appearance.apply() }
    }

    /// 已注册为登录项（包括等待用户在系统设置中批准的情况）
    private static var isLoginItemEnabled: Bool {
        [.enabled, .requiresApproval].contains(SMAppService.mainApp.status)
    }

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    func refresh() {
        launchAtLogin = Self.isLoginItemEnabled
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            if SMAppService.mainApp.status == .requiresApproval {
                // 需要用户在"系统设置 > 通用 > 登录项"中允许
                SMAppService.openSystemSettingsLoginItems()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = enabled ? "无法设置自动启动" : "无法取消自动启动"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        refresh()
    }

    var button: some View {
        AppMenuButton(menu: self)
    }
}

private struct AppMenuButton: View {
    @ObservedObject var menu: AppMenu
    @ObservedObject var store = DataStore.shared

    var body: some View {
        Menu {
            Toggle("自动启动", isOn: Binding(get: { menu.launchAtLogin }, set: { menu.setLaunchAtLogin($0) }))
            Picker("外观", selection: $menu.appearance) {
                ForEach(AppearanceMode.allCases) { Text($0.title).tag($0) }
            }
            Menu("显示节日") {
                ForEach(FestivalCategory.allCases) { category in
                    Toggle(category.title, isOn: Binding(
                        get: { !store.hiddenCategories.contains(category) },
                        set: { store.setCategory(category, visible: $0) }))
                }
            }
            Button("自定义日期…") { menu.onEditCustomEvents() }
            Divider()
            Button("使用帮助") { NSWorkspace.shared.open(AppMenu.helpURL) }
            Button("更新假日信息…") { menu.onUpdateHolidays() }
            Divider()
            Button("版本: \(AppMenu.version)") { NSWorkspace.shared.open(AppMenu.changelogURL) }
            Button("万年历 © zfdang") { NSWorkspace.shared.open(AppMenu.contactURL) }
            Divider()
            Button("退出") { NSApp.terminate(nil) }
        } label: {
            Image(systemName: "gearshape")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("设置")
        .onAppear { menu.refresh() }
    }
}
