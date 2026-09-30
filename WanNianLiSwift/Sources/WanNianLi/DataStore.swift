import Foundation
import LunarCore

/// 管理日历数据文件（holidays.js / festivals.js / events.js）。
///
/// 数据文件保存在 "~/Library/Application Support/com.zfdang.calendar" 中，与旧版应用共用：
/// - 用户可以直接编辑其中的 festivals.js、events.js 来增加自己的节日和事件
/// - "更新假日信息"会下载最新的 holidays.js 覆盖其中的文件
@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()

    /// 在线更新假日信息的地址（与旧版应用使用同一个文件，每年只需维护这一份）
    static let holidaysRemoteURL = URL(string: "https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/WanNianLi/WanNianLi/Resources/vendors/holidays.js")!

    @Published private(set) var data = CalendarData()

    let supportDirectory: URL

    private init() {
        if let override = ProcessInfo.processInfo.environment["WANNIANLI_DATA_DIR"] {
            // 开发 / 测试时使用单独的数据目录，避免改动真实数据
            supportDirectory = URL(fileURLWithPath: override, isDirectory: true)
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            supportDirectory = base.appendingPathComponent("com.zfdang.calendar", isDirectory: true)
        }
        installBundledData()
        reload()
    }

    func reload() {
        data = CalendarData.load(from: supportDirectory)
    }

    var holidaysFile: URL { supportDirectory.appendingPathComponent(CalendarData.holidaysFile) }

    /// 本地 holidays.js 的版本号
    var localHolidaysVersion: String {
        JSDataParser.version(in: (try? String(contentsOf: holidaysFile, encoding: .utf8)) ?? "")
    }

    /// 用下载的内容替换本地 holidays.js
    func replaceHolidays(with content: Data) throws {
        try content.write(to: holidaysFile, options: .atomic)
        reload()
    }

    // MARK: - 安装内置数据

    /// 应用内置的数据文件目录
    private var bundledDirectory: URL? {
        var candidates = [Bundle.main.resourceURL?.appendingPathComponent("calendar-data")]
        #if DEBUG
        // 开发时（swift run）直接使用源码目录中的数据
        candidates.append(URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Resources/calendar-data"))
        #endif
        return candidates.compactMap { $0 }.first {
            FileManager.default.fileExists(atPath: $0.appendingPathComponent(CalendarData.holidaysFile).path)
        }
    }

    /// 把内置数据复制到 Application Support 目录：
    /// - holidays.js：本地没有，或者内置版本（文件首行的 Version）更新时复制
    /// - festivals.js、events.js：用户可以自行修改，只在本地没有时复制，不会覆盖
    private func installBundledData() {
        let fm = FileManager.default
        try? fm.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
        guard let source = bundledDirectory else {
            NSLog("WanNianLi: bundled calendar data not found")
            return
        }

        func text(_ dir: URL, _ name: String) -> String? {
            try? String(contentsOf: dir.appendingPathComponent(name), encoding: .utf8)
        }
        func copy(_ name: String) {
            do {
                // 原子写入，复制失败时保留原文件
                let content = try Data(contentsOf: source.appendingPathComponent(name))
                try content.write(to: supportDirectory.appendingPathComponent(name), options: .atomic)
            } catch {
                NSLog("WanNianLi: failed to copy \(name): \(error.localizedDescription)")
            }
        }

        if let bundled = text(source, CalendarData.holidaysFile) {
            let local = text(supportDirectory, CalendarData.holidaysFile)
            if local == nil || JSDataParser.isVersion(JSDataParser.version(in: bundled), newerThan: JSDataParser.version(in: local!)) {
                copy(CalendarData.holidaysFile)
            }
        }

        for name in [CalendarData.festivalsFile, CalendarData.eventsFile]
        where !fm.fileExists(atPath: supportDirectory.appendingPathComponent(name).path) {
            copy(name)
        }
    }
}
