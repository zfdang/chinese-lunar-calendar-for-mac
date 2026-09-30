import Foundation
import LunarCore

/// 管理日历数据：调休安排（holidays.json）、内置节日的显示设置、自定义事件（custom-events.json）。
///
/// 数据保存在 "~/Library/Application Support/com.zfdang.calendar" 中：
/// - holidays.json：在线更新下载的调休安排（比内置版本新时才使用）
/// - custom-events.json：用户自定义的日期、节日和事件
@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()

    /// 在线更新调休安排的地址
    static let holidaysRemoteURL = URL(string: "https://raw.githubusercontent.com/zfdang/chinese-lunar-calendar-for-mac/master/WanNianLiSwift/Resources/calendar-data/holidays.json")!

    /// 自动检查更新的间隔
    private static let autoCheckInterval: TimeInterval = 7 * 24 * 3600
    private static let lastCheckKey = "holidaysLastCheck"
    private static let hiddenCategoriesKey = "hiddenFestivalCategories"

    @Published private(set) var data = CalendarData()
    @Published private(set) var holidays: HolidayData?
    @Published private(set) var customEvents: [CustomEvent] = []
    @Published private(set) var hiddenCategories: Set<FestivalCategory> = []

    let supportDirectory: URL
    private var autoCheckTimer: Timer?

    private init() {
        if let override = ProcessInfo.processInfo.environment["WANNIANLI_DATA_DIR"] {
            // 开发 / 测试时使用单独的数据目录，避免改动真实数据
            supportDirectory = URL(fileURLWithPath: override, isDirectory: true)
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            supportDirectory = base.appendingPathComponent("com.zfdang.calendar", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: supportDirectory, withIntermediateDirectories: true)

        hiddenCategories = Set((UserDefaults.standard.stringArray(forKey: Self.hiddenCategoriesKey) ?? [])
            .compactMap(FestivalCategory.init))
        loadHolidays()
        loadCustomEvents()
        rebuild()
    }

    private func rebuild() {
        let festivals = Festival.builtin.filter { !hiddenCategories.contains($0.category) }
        data = CalendarData(holidays: holidays, festivals: festivals, customEvents: customEvents)
    }

    // MARK: - 调休安排

    private var downloadedHolidaysFile: URL { supportDirectory.appendingPathComponent("holidays.json") }

    /// 应用内置的 holidays.json
    private var bundledHolidaysFile: URL? {
        var candidates = [Bundle.main.resourceURL?.appendingPathComponent("calendar-data/holidays.json")]
        #if DEBUG
        // 开发时（swift run）直接使用源码目录中的数据
        candidates.append(URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Resources/calendar-data/holidays.json"))
        #endif
        return candidates.compactMap { $0 }.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    /// 使用内置和已下载的数据中版本较新的一份
    private func loadHolidays() {
        let bundled = bundledHolidaysFile.flatMap(HolidayData.load)
        let downloaded = HolidayData.load(from: downloadedHolidaysFile)
        if let downloaded, downloaded.isNewer(than: bundled) {
            holidays = downloaded
        } else {
            holidays = bundled ?? downloaded
        }
    }

    var holidaysVersion: String { holidays?.version ?? "0" }

    /// 下载最新的调休安排；返回下载到的内容（不保存）
    func fetchRemoteHolidays() async throws -> (content: Data, holidays: HolidayData) {
        let request = URLRequest(url: Self.holidaysRemoteURL, cachePolicy: .reloadIgnoringLocalCacheData)
        let (content, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        guard let holidays = HolidayData.decode(content) else { throw URLError(.cannotParseResponse) }
        UserDefaults.standard.set(Date(), forKey: Self.lastCheckKey)
        return (content, holidays)
    }

    func saveHolidays(_ content: Data) throws {
        try content.write(to: downloadedHolidaysFile, options: .atomic)
        loadHolidays()
        rebuild()
    }

    /// 启动时及之后每天检查一次，距上次检查超过 7 天时在后台更新调休安排
    func startAutomaticHolidayUpdates() {
        checkHolidaysIfDue()
        autoCheckTimer = Timer.scheduledTimer(withTimeInterval: 24 * 3600, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.checkHolidaysIfDue() }
        }
    }

    private func checkHolidaysIfDue() {
        let last = UserDefaults.standard.object(forKey: Self.lastCheckKey) as? Date ?? .distantPast
        guard Date().timeIntervalSince(last) > Self.autoCheckInterval else { return }
        Task {
            guard let (content, remote) = try? await fetchRemoteHolidays(), remote.isNewer(than: holidays) else { return }
            try? saveHolidays(content)
        }
    }

    // MARK: - 内置节日

    func setCategory(_ category: FestivalCategory, visible: Bool) {
        if visible { hiddenCategories.remove(category) } else { hiddenCategories.insert(category) }
        UserDefaults.standard.set(hiddenCategories.map(\.rawValue).sorted(), forKey: Self.hiddenCategoriesKey)
        rebuild()
    }

    // MARK: - 自定义事件

    private var customEventsFile: URL { supportDirectory.appendingPathComponent("custom-events.json") }

    private func loadCustomEvents() {
        if let content = try? Data(contentsOf: customEventsFile),
           let file = try? JSONDecoder().decode(CustomEventsFile.self, from: content) {
            customEvents = file.events
            return
        }
        if FileManager.default.fileExists(atPath: customEventsFile.path) {
            NSLog("WanNianLi: custom-events.json cannot be parsed, keeping it untouched")
            return
        }
        // 第一次运行：从旧版的 festivals.js / events.js 中导入用户自己添加的条目
        func read(_ name: String) -> String {
            (try? String(contentsOf: supportDirectory.appendingPathComponent(name), encoding: .utf8)) ?? ""
        }
        customEvents = LegacyImporter.customEvents(festivalsJS: read("festivals.js"), eventsJS: read("events.js"))
        saveCustomEvents()
    }

    private func saveCustomEvents() {
        do {
            try Self.encode(customEvents).write(to: customEventsFile, options: .atomic)
        } catch {
            NSLog("WanNianLi: failed to save custom events: \(error.localizedDescription)")
        }
    }

    static func encode(_ events: [CustomEvent]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(CustomEventsFile(events: events))
    }

    func setCustomEvents(_ events: [CustomEvent]) {
        customEvents = events
        saveCustomEvents()
        rebuild()
    }

    func upsert(_ event: CustomEvent) {
        var events = customEvents
        if let i = events.firstIndex(where: { $0.id == event.id }) { events[i] = event } else { events.append(event) }
        setCustomEvents(events)
    }

    func delete(ids: Set<UUID>) {
        setCustomEvents(customEvents.filter { !ids.contains($0.id) })
    }

    /// 导出为 JSON
    func exportCustomEvents(to url: URL) throws {
        try Self.encode(customEvents).write(to: url, options: .atomic)
    }

    /// 导入 JSON（本程序导出的文件）或旧版的 festivals.js / events.js，跳过重复的条目；返回新增的数量
    func importCustomEvents(from url: URL) throws -> Int {
        let content = try Data(contentsOf: url)
        let imported: [CustomEvent]
        if url.pathExtension.lowercased() == "js" {
            let text = String(decoding: content, as: UTF8.self)
            imported = LegacyImporter.customEvents(festivalsJS: text, eventsJS: text)
        } else {
            imported = try JSONDecoder().decode(CustomEventsFile.self, from: content).events
        }
        var events = customEvents
        var added = 0
        for var event in imported where !events.contains(where: { $0.isDuplicate(of: event) }) {
            if events.contains(where: { $0.id == event.id }) { event.id = UUID() }
            events.append(event)
            added += 1
        }
        setCustomEvents(events)
        return added
    }
}
