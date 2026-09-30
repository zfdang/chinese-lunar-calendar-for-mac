import AppKit
import LunarCore
import SwiftUI

/// 开发用：`WanNianLi --snapshot <目录> [yyyyMMdd]` 把日历界面和菜单栏图标渲染成 PNG，便于检查界面
@MainActor
enum Snapshot {
    static func run(arguments: [String]) {
        let dir = URL(fileURLWithPath: arguments[0], isDirectory: true)
        let model = CalendarViewModel(store: DataStore.shared)
        if arguments.count > 1, let key = Int(arguments[1]) {
            model.setYear(key / 10000)
            model.setMonth(key / 100 % 100)
            model.select(CalendarDay(date: SolarDate(year: key / 10000, month: key / 100 % 100, day: key % 100),
                                     data: DataStore.shared.data))
        }
        for (name, appearance) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
            let view = NSHostingView(rootView: CalendarView(model: model, menu: AppMenu())
                .background(Color(nsColor: .windowBackgroundColor)))
            view.appearance = NSAppearance(named: appearance)
            view.frame.size = view.fittingSize
            let window = NSWindow(contentRect: view.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.appearance = NSAppearance(named: appearance)
            window.backgroundColor = appearance == .aqua ? .white : NSColor(white: 0.16, alpha: 1)
            window.contentView = view
            view.layoutSubtreeIfNeeded()
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
            save(view, to: dir.appendingPathComponent("calendar-\(name).png"))
        }
        // 自定义日期窗口（选中第一项）
        let events = NSHostingView(rootView: CustomEventsView(store: DataStore.shared,
                                                              selection: DataStore.shared.customEvents.first?.id))
        events.frame.size = NSSize(width: 680, height: 440)
        let window = NSWindow(contentRect: events.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = events
        events.layoutSubtreeIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        save(events, to: dir.appendingPathComponent("custom-events.png"))

        let icon = NSImageView(image: MenuBarIcon.image(day: SolarDate.today.day))
        icon.frame = NSRect(x: 0, y: 0, width: 20, height: 18)
        save(icon, to: dir.appendingPathComponent("icon.png"))
    }

    private static func save(_ view: NSView, to url: URL) {
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
        print("saved \(url.path) \(Int(view.bounds.width))x\(Int(view.bounds.height))")
    }
}
