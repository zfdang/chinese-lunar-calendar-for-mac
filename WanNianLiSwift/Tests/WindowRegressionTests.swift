import AppKit
import Foundation

@MainActor
final class WindowTestDelegate: NSObject, NSApplicationDelegate {
    private var controller: StatusItemController?
    private let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = DataStore(supportDirectory: directory)
        controller = StatusItemController(store: store)
        controller?.testOpenCustomEventsFromCalendar()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard let window = NSApp.windows.first(where: { $0.title == "自定义日期" && $0.isVisible }),
                  let visible = window.screen?.visibleFrame else {
                FileHandle.standardError.write(Data("custom dates window did not appear\n".utf8))
                exit(1)
            }
            guard visible.contains(window.frame) else {
                FileHandle.standardError.write(Data("custom dates window is outside the visible screen\n".utf8))
                exit(1)
            }
            guard window.occlusionState.contains(.visible) else {
                FileHandle.standardError.write(Data("custom dates window: visible=\(window.occlusionState.contains(.visible))\n".utf8))
                exit(1)
            }
            print("ok   custom dates window is visible within the screen")
            try? FileManager.default.removeItem(at: directory)
            NSApp.terminate(nil)
        }
    }
}

@main
struct WindowRegressionTests {
    @MainActor static func main() {
        let app = NSApplication.shared
        let delegate = WindowTestDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }
}
