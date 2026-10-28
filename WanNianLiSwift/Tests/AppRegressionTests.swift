import Foundation
import CoreGraphics
import LunarCore

/// 直接编译应用的数据层，保持仅安装 Command Line Tools 时也能运行回归测试。
@main
struct AppRegressionTests {
    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else { fatalError(message) }
        print("ok   " + message)
    }

    static func expectFailure(_ message: String, _ operation: () throws -> Void) {
        do {
            try operation()
            fatalError("Expected failure: " + message)
        } catch {
            print("ok   " + message)
        }
    }

    @MainActor
    static func main() throws {
        let screen = CGRect(x: -1440, y: 0, width: 1440, height: 900)
        let anchor = CGRect(x: -500, y: 370, width: 460, height: 500)
        let size = CGSize(width: 680, height: 460)
        let origin = WindowPlacement.origin(size: size, near: anchor, in: screen)
        let placed = CGRect(origin: origin, size: size)
        check(screen.contains(placed) && placed.maxX <= anchor.minX,
              "custom dates window fits beside the calendar on a secondary screen")
        let smallScreen = CGRect(x: 0, y: 0, width: 800, height: 600)
        let smallAnchor = CGRect(x: 200, y: 100, width: 460, height: 500)
        let fallback = WindowPlacement.origin(size: size, near: smallAnchor, in: smallScreen)
        check(smallScreen.contains(CGRect(origin: fallback, size: size)),
              "custom dates window remains visible when there is no room beside the calendar")
        let upcomingData = CalendarData(holidays: nil, festivals: [], customEvents: [
            CustomEvent(name: "Today", rule: .once(year: 2026, month: 12, day: 31)),
            CustomEvent(name: "New year", rule: .solar(month: 1, day: 1)),
            CustomEvent(name: "Another event", rule: .once(year: 2027, month: 1, day: 1)),
            CustomEvent(name: "Later", rule: .once(year: 2027, month: 1, day: 4)),
        ])
        let start = SolarDate(year: 2026, month: 12, day: 31)
        let upcoming = UpcomingEvents.find(from: start, data: upcomingData, days: 4)
        check(upcoming.map(\.name) == ["Today", "Another event", "New year"],
              "upcoming events include today and preserve ordering across years")
        check(upcoming.map(\.daysAway) == [0, 1, 1], "upcoming events calculate calendar-day distances")
        check(UpcomingEvents.find(from: start, data: upcomingData, days: 4, limit: 2).count == 2,
              "upcoming event limit is respected")
        let crowdedData = CalendarData(holidays: nil, festivals: [], customEvents: (1...8).map {
            CustomEvent(name: "Event \($0)", rule: .once(year: 2026, month: 12, day: 31))
        })
        check(UpcomingEvents.find(from: start, data: crowdedData, days: 1).count == 6,
              "upcoming list defaults to six events even on a busy day")
        check(UpcomingEvents.find(from: start, data: upcomingData, days: 0).isEmpty,
              "an empty date range returns no events")
        let term = UpcomingEvents.find(from: SolarDate(year: 2026, month: 12, day: 22),
                                       data: CalendarData(), days: 1)
        check(term.contains { $0.name == "冬至" }, "upcoming events include solar terms")
        let lunarData = CalendarData(holidays: nil, festivals: [], customEvents: [
            CustomEvent(name: "Lunar new year", rule: .lunar(month: 1, day: 1))
        ])
        let lunar = UpcomingEvents.find(from: SolarDate(year: 2026, month: 2, day: 17), data: lunarData, days: 1)
        check(lunar.contains { $0.name == "Lunar new year" }, "upcoming events resolve lunar dates")
        check(UpcomingEvents.find(from: SolarDate(year: 2099, month: 12, day: 31),
                                  data: CalendarData(), days: 90).allSatisfy { $0.day.date.year == 2099 },
              "upcoming events stop at the supported year boundary")

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = DataStore(supportDirectory: directory)
        var event = CustomEvent(name: "Birthday", rule: .solar(month: 1, day: 1))
        try store.upsert(event)
        event.name = "Edited birthday"
        try store.update(event)
        try store.delete(ids: [event.id])
        // 编辑器消失时 flush 的旧草稿，以及未完成的延迟保存，均走 update。
        try store.update(event)
        check(store.customEvents.isEmpty, "delayed editor save does not restore deleted event")
        let reloaded = DataStore(supportDirectory: directory)
        check(reloaded.customEvents.isEmpty, "deleted event stays deleted after reload")

        try store.upsert(event)
        let target = directory.appendingPathComponent("custom-events.json")
        let saved = try Data(contentsOf: target)
        let original = store.customEvents
        let importFile = directory.appendingPathComponent("import.json")
        let added = CustomEvent(name: "New event", rule: .solar(month: 2, day: 1))
        try DataStore.encode([added]).write(to: importFile)

        // 目标是目录时，原子写入必定失败，不依赖执行用户的权限或磁盘容量。
        try FileManager.default.removeItem(at: target)
        try FileManager.default.createDirectory(at: target, withIntermediateDirectories: false)
        expectFailure("adding reports persistence failure") { try store.upsert(added) }
        var edited = event
        edited.name = "Unsaved edit"
        expectFailure("editing reports persistence failure") { try store.update(edited) }
        expectFailure("deleting reports persistence failure") { try store.delete(ids: [event.id]) }
        expectFailure("importing reports persistence failure") { _ = try store.importCustomEvents(from: importFile) }
        check(store.customEvents == original, "failed writes leave the event list unchanged")
        let day = CalendarDay(date: SolarDate(year: 2026, month: 1, day: 1), data: store.data)
        check(day.events.contains { $0.name == event.name }, "failed writes leave calendar data unchanged")
        try FileManager.default.removeItem(at: target)
        try saved.write(to: target)
        check(DataStore(supportDirectory: directory).customEvents == original, "previous data survives reload")
        try store.update(edited)
        check(DataStore(supportDirectory: directory).customEvents == [edited], "saving works after storage recovers")
        let invalid = CustomEvent(name: "Invalid", rule: .lunar(month: 13, day: 1))
        // 使用原始编码器模拟外部提供的非法 JSON，绕过应用的保存校验。
        let badJSON = try JSONEncoder().encode(CustomEventsFile(events: [invalid]))
        try badJSON.write(to: importFile)
        let beforeImport = try Data(contentsOf: target)
        expectFailure("invalid JSON import is rejected") { _ = try store.importCustomEvents(from: importFile) }
        check(store.customEvents == [edited], "invalid import leaves memory unchanged")
        let afterImport = try Data(contentsOf: target)
        check(afterImport == beforeImport, "invalid import leaves disk unchanged")

        let damagedDirectory = directory.appendingPathComponent("damaged")
        try FileManager.default.createDirectory(at: damagedDirectory, withIntermediateDirectories: false)
        try badJSON.write(to: damagedDirectory.appendingPathComponent("custom-events.json"))
        let recovered = DataStore(supportDirectory: damagedDirectory)
        check(recovered.customEvents.isEmpty && recovered.loadWarning != nil, "invalid startup data produces a warning")
        let backups = try FileManager.default.contentsOfDirectory(at: damagedDirectory, includingPropertiesForKeys: nil)
        check(backups.count == 1 && backups[0].lastPathComponent.hasPrefix("custom-events.broken-"),
              "invalid startup data is backed up")
        let backupContent = try Data(contentsOf: backups[0])
        check(backupContent == badJSON, "backup preserves the original bytes")
    }
}
