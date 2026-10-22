import Foundation
import LunarCore

/// 直接编译应用的数据层，保持仅安装 Command Line Tools 时也能运行回归测试。
@main
struct AppRegressionTests {
    static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else { fatalError(message) }
        print("ok   " + message)
    }

    @MainActor
    static func main() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = DataStore(supportDirectory: directory)
        var event = CustomEvent(name: "Birthday", rule: .solar(month: 1, day: 1))
        store.upsert(event)
        event.name = "Edited birthday"
        store.update(event)
        store.delete(ids: [event.id])
        // 编辑器消失时 flush 的旧草稿，以及未完成的延迟保存，均走 update。
        store.update(event)
        check(store.customEvents.isEmpty, "delayed editor save does not restore deleted event")
        let reloaded = DataStore(supportDirectory: directory)
        check(reloaded.customEvents.isEmpty, "deleted event stays deleted after reload")
    }
}
