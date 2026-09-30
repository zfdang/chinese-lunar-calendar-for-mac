import AppKit
import LunarCore
import SwiftUI

/// 菜单栏图标及日历弹出窗口
@MainActor
final class StatusItemController: NSObject, NSPopoverDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private let store = DataStore.shared
    private let model: CalendarViewModel
    private let menu = AppMenu()

    private var shownDay: SolarDate?
    private var timer: Timer?
    private var keyMonitor: Any?
    private var updateWindow: UpdateHolidaysWindowController?
    private var customEventsWindow: CustomEventsWindowController?
    private var lastClosed = Date.distantPast

    override init() {
        model = CalendarViewModel(store: store)
        super.init()

        menu.onUpdateHolidays = { [weak self] in self?.showUpdateWindow() }
        menu.onEditCustomEvents = { [weak self] in self?.showCustomEventsWindow() }

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseDown, .rightMouseDown])
        }

        let hosting = NSHostingController(rootView: CalendarView(model: model, menu: menu))
        hosting.sizingOptions = .preferredContentSize
        popover.contentViewController = hosting
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        refreshIcon()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAppearance),
                                               name: AppearanceMode.didChange, object: nil)
        // 每 5 秒检查一次日期是否变化
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshIcon() }
        }
    }

    private func refreshIcon() {
        let today = SolarDate.today
        guard today != shownDay, let button = statusItem.button else { return }
        shownDay = today
        model.refreshToday()
        button.image = MenuBarIcon.image(day: today.day)
        let day = CalendarDay(date: today, data: store.data)
        button.toolTip = "\(day.solarText) \(day.weekdayName)\n\(day.lunarText)"
    }

    // MARK: - 弹出窗口

    @objc private func togglePopover() {
        // 弹出窗口打开时点击图标：transient 行为会先关闭窗口，这里不要再立即打开
        if Date().timeIntervalSince(lastClosed) < 0.3 { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        // 每次打开时回到今天
        model.showToday()
        refreshIcon()

        updateAppearance()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        button.highlight(true)
        NSApp.activate(ignoringOtherApps: true)
        popover.contentViewController?.view.window?.makeKey()

        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.popover.isShown else { return event }
            return self.handleKey(event) ? nil : event
        }
    }

    // 应用激活是异步的，弹出窗口显示时可能还没激活，这里再次让它成为键盘焦点窗口，
    // 否则方向键、回车无法控制日历
    func popoverDidShow(_ notification: Notification) {
        popover.contentViewController?.view.window?.makeKey()
        installOpaqueBackground()
    }

    /// 弹出窗口默认跟随菜单栏按钮的外观，而不是 NSApp.appearance，这里显式设置
    @objc private func updateAppearance() {
        popover.appearance = NSApp.appearance ?? NSApp.effectiveAppearance
        popover.contentViewController?.view.window?.contentView?.superview?.subviews
            .filter { $0 is PopoverBackgroundView }
            .forEach { $0.needsDisplay = true }
    }

    /// 把弹出窗口箭头部分的半透明材质也换成不透明背景。
    /// 依赖 NSPopover 内部的视图层级（contentView.superview），如果系统改变了层级，
    /// 只有箭头会恢复为半透明，内容区域的背景由 CalendarView 自己绘制，不受影响
    private func installOpaqueBackground() {
        guard let frameView = popover.contentViewController?.view.window?.contentView?.superview,
              !frameView.subviews.contains(where: { $0 is PopoverBackgroundView }) else { return }
        let background = PopoverBackgroundView(frame: frameView.bounds)
        background.autoresizingMask = [.width, .height]
        frameView.addSubview(background, positioned: .below, relativeTo: nil)
    }

    @objc private func applicationDidBecomeActive() {
        if popover.isShown { popover.contentViewController?.view.window?.makeKey() }
    }

    func popoverDidClose(_ notification: Notification) {
        lastClosed = Date()
        statusItem.button?.highlight(false)
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
    }

    /// 键盘控制：← 上一年，→ 下一年，↑ 上一月，↓ 下一月，↵ 回到今天
    private func handleKey(_ event: NSEvent) -> Bool {
        let moved: Bool
        switch event.keyCode {
        case 123: moved = model.moveYear(by: -1)
        case 124: moved = model.moveYear(by: 1)
        case 126: moved = model.moveMonth(by: -1)
        case 125: moved = model.moveMonth(by: 1)
        case 36, 76: model.showToday(); moved = true
        default: return false
        }
        if !moved { NSSound.beep() }
        return true
    }

    // MARK: - 自定义日期

    private func showCustomEventsWindow() {
        popover.performClose(nil)
        if customEventsWindow == nil {
            customEventsWindow = CustomEventsWindowController(store: store) { [weak self] in
                self?.customEventsWindow = nil
            }
        }
        NSApp.activate(ignoringOtherApps: true)
        customEventsWindow?.showWindow(nil)
        customEventsWindow?.window?.makeKeyAndOrderFront(nil)
    }

    // MARK: - 更新假日信息

    private func showUpdateWindow() {
        popover.performClose(nil)
        if updateWindow == nil {
            updateWindow = UpdateHolidaysWindowController(store: store) { [weak self] in
                self?.updateWindow = nil
            }
        }
        NSApp.activate(ignoringOtherApps: true)
        updateWindow?.showWindow(nil)
        updateWindow?.window?.makeKeyAndOrderFront(nil)
    }
}


/// 弹出窗口的不透明背景
private final class PopoverBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        Palette.nsBackground.setFill()
        bounds.fill()
    }
}
