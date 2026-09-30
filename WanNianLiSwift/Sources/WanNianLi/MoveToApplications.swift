import AppKit

/// 如果应用不在"应用程序"文件夹中运行，询问用户是否移动过去（替代原来的 LetsMove / PFMoveApplication）
@MainActor
enum MoveToApplications {
    private static let suppressKey = "moveToApplicationsFolderAlertSuppress"

    static func promptIfNecessary() {
        let bundleURL = Bundle.main.bundleURL.resolvingSymlinksInPath()
        guard bundleURL.pathExtension == "app",
              !UserDefaults.standard.bool(forKey: suppressKey) else { return }

        let applicationDirs = FileManager.default.urls(for: .applicationDirectory, in: [.localDomainMask, .userDomainMask])
        if applicationDirs.contains(where: { bundleURL.path.hasPrefix($0.resolvingSymlinksInPath().path + "/") }) {
            return
        }

        let alert = NSAlert()
        alert.messageText = "要把万年历移动到“应用程序”文件夹吗？"
        alert.informativeText = "移动之后，可以更方便地使用“自动启动”等功能。"
        alert.addButton(withTitle: "移动到“应用程序”文件夹")
        alert.addButton(withTitle: "暂不移动")
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "不再询问"

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if alert.suppressionButton?.state == .on {
            UserDefaults.standard.set(true, forKey: suppressKey)
        }
        guard response == .alertFirstButtonReturn else { return }

        let fm = FileManager.default
        let destination = URL(fileURLWithPath: "/Applications").appendingPathComponent(bundleURL.lastPathComponent)

        // "应用程序"文件夹中的旧版本正在运行时不能替换
        let running = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "")
        if running.contains(where: { $0.processIdentifier != getpid() && $0.bundleURL?.resolvingSymlinksInPath() == destination.resolvingSymlinksInPath() }) {
            showError("“应用程序”文件夹中的万年历正在运行，请先退出它再试。")
            return
        }

        // 先复制到临时名称，成功后再替换，失败时不会丢失已安装的版本
        let staging = destination.deletingLastPathComponent()
            .appendingPathComponent(".\(bundleURL.lastPathComponent).\(UUID().uuidString)")
        do {
            try fm.copyItem(at: bundleURL, to: staging)
            if fm.fileExists(atPath: destination.path) {
                _ = try fm.replaceItemAt(destination, withItemAt: staging)
            } else {
                try fm.moveItem(at: staging, to: destination)
            }
        } catch {
            try? fm.removeItem(at: staging)
            showError(error.localizedDescription)
            return
        }
        // 原位置的副本放到废纸篓（从只读磁盘映像或 App Translocation 运行时会失败，忽略即可）
        try? fm.trashItem(at: bundleURL, resultingItemURL: nil)

        // 等当前进程退出后再启动新位置的应用
        let relaunch = Process()
        relaunch.executableURL = URL(fileURLWithPath: "/bin/sh")
        relaunch.arguments = ["-c", "while kill -0 \"$1\" 2>/dev/null; do sleep 0.1; done; /usr/bin/open \"$0\"",
                              destination.path, String(getpid())]
        try? relaunch.run()
        NSApp.terminate(nil)
    }

    private static func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "无法移动到“应用程序”文件夹"
        alert.informativeText = message
        alert.runModal()
    }
}
