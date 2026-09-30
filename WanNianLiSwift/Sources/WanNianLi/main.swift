import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppearanceMode.saved.apply()
        MoveToApplications.promptIfNecessary()
        statusItemController = StatusItemController()
    }
}

let app = NSApplication.shared
if let index = CommandLine.arguments.firstIndex(of: "--snapshot") {
    MainActor.assumeIsolated { Snapshot.run(arguments: Array(CommandLine.arguments[(index + 1)...])) }
    exit(0)
}
MainActor.assumeIsolated {
    let delegate = AppDelegate()
    app.delegate = delegate
    // 只在菜单栏显示，不出现在 Dock 中
    app.setActivationPolicy(.accessory)
    withExtendedLifetime(delegate) { app.run() }
}
