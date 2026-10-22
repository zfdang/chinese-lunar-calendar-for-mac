import Foundation
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
