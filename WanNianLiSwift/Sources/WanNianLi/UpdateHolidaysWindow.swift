import AppKit
import LunarCore
import SwiftUI

/// "更新假日信息"窗口：下载最新的 holidays.json，版本更新时保存到本地
@MainActor
final class UpdateHolidaysModel: ObservableObject {
    enum State: Equatable {
        case checking
        case failed(String)
        case upToDate
        case updateAvailable
        case updating
        case updated
    }

    @Published private(set) var state = State.checking
    @Published private(set) var localVersion = ""
    @Published private(set) var remoteVersion = ""

    private let store: DataStore
    private var downloaded: Data?

    init(store: DataStore) {
        self.store = store
    }

    func check() async {
        state = .checking
        localVersion = store.holidaysVersion
        remoteVersion = ""
        do {
            let (content, remote) = try await store.fetchRemoteHolidays()
            downloaded = content
            remoteVersion = remote.version
            state = remote.isNewer(than: store.holidays) ? .updateAvailable : .upToDate
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func update() async {
        guard let downloaded else { return }
        state = .updating
        // 稍作停顿，让用户感知到更新过程
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        do {
            try store.saveHolidays(downloaded)
            localVersion = store.holidaysVersion
            state = .updated
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

struct UpdateHolidaysView: View {
    @ObservedObject var model: UpdateHolidaysModel
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 10) {
                    GridRow {
                        Text("当前版本：")
                        if model.state == .updating { ProgressView().controlSize(.small) }
                        else { Text(model.localVersion).monospacedDigit() }
                    }
                    GridRow {
                        Text("最新版本：")
                        if model.state == .checking { ProgressView().controlSize(.small) }
                        else { Text(model.remoteVersion.isEmpty ? "—" : model.remoteVersion).monospacedDigit() }
                    }
                }
                Spacer()
                switch model.state {
                case .updateAvailable:
                    Button("更新") { Task { await model.update() } }
                        .keyboardShortcut(.defaultAction)
                case .upToDate, .updated, .failed:
                    Button("关闭", action: close)
                        .keyboardShortcut(.defaultAction)
                case .checking, .updating:
                    EmptyView()
                }
            }
            if case .failed(let message) = model.state {
                Text("下载失败：\(message)")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            } else if model.state == .updated {
                Text("假日信息已更新。").font(.callout).foregroundStyle(.secondary)
            } else if model.state == .upToDate {
                Text("已经是最新版本。").font(.callout).foregroundStyle(.secondary)
            }
            Divider()
            Text("假日信息指国务院发布的年度节假日调整信息，包括工作日放假和周末调整为工作日。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 2) {
                Text("查看最新假日信息：")
                Link("holidays.json", destination: DataStore.holidaysRemoteURL)
            }
            .font(.callout)
        }
        .padding(20)
        .frame(width: 320)
        .task { await model.check() }
    }
}

@MainActor
final class UpdateHolidaysWindowController: NSWindowController, NSWindowDelegate {
    private var onClose: () -> Void = {}

    convenience init(store: DataStore, onClose: @escaping () -> Void) {
        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        self.init(window: window)
        self.onClose = onClose
        window.title = "更新假日信息"
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentViewController = NSHostingController(
            rootView: UpdateHolidaysView(model: UpdateHolidaysModel(store: store)) { [weak window] in window?.close() })
        window.center()
    }

    func windowWillClose(_ notification: Notification) {
        // 延后释放，避免在窗口关闭过程中销毁自己
        DispatchQueue.main.async { [onClose] in onClose() }
    }
}
