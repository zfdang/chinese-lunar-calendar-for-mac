import AppKit
import LunarCore
import SwiftUI
import UniformTypeIdentifiers

/// "自定义日期"窗口：管理用户自己的日期、节日和事件，支持导入 / 导出
struct CustomEventsView: View {
    @ObservedObject var store: DataStore
    @State var selection: UUID?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(store.customEvents) { event in
                        EventRow(event: event).tag(event.id)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: false))
                Divider()
                toolbar
            }
            .frame(width: 250)

            Divider()

            Group {
                if let id = selection, let event = store.customEvents.first(where: { $0.id == id }) {
                    EventEditor(event: event) { store.upsert($0) }
                        .id(id)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text(store.customEvents.isEmpty ? "点击左下角的 + 添加生日、纪念日等日期" : "选择左侧的一项进行编辑")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 640, minHeight: 400)
    }

    private var toolbar: some View {
        HStack(spacing: 6) {
            Button { add() } label: { Image(systemName: "plus").frame(width: 14) }
                .help("添加")
            Button { deleteSelected() } label: { Image(systemName: "minus").frame(width: 14) }
                .help("删除")
                .disabled(selection == nil)
            Spacer(minLength: 12)
            Button { importEvents() } label: { Label("导入", systemImage: "square.and.arrow.down") }
                .help("从 JSON 文件或旧版 festivals.js / events.js 导入")
            Button { exportEvents() } label: { Label("导出", systemImage: "square.and.arrow.up") }
                .help("导出为 JSON 文件")
                .disabled(store.customEvents.isEmpty)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .padding(8)
    }

    private func add() {
        let today = SolarDate.today
        let event = CustomEvent(name: "新的日期", rule: .solar(month: today.month, day: today.day), highlight: true)
        store.upsert(event)
        selection = event.id
    }

    private func deleteSelected() {
        guard let id = selection, let event = store.customEvents.first(where: { $0.id == id }) else { return }
        let alert = NSAlert()
        alert.messageText = "删除“\(event.name)”？"
        alert.informativeText = event.rule.description
        alert.addButton(withTitle: "删除")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        store.delete(ids: [id])
        selection = nil
    }

    private func importEvents() {
        let panel = NSOpenPanel()
        panel.title = "导入自定义日期"
        panel.message = "选择导出的 JSON 文件，或者旧版的 festivals.js / events.js"
        panel.allowedContentTypes = [.json, .javaScript]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let added = try store.importCustomEvents(from: url)
            showMessage("导入完成", added == 0 ? "没有新的日期（已存在的条目会自动跳过）。" : "新增了 \(added) 个日期。")
        } catch {
            showMessage("无法导入", error.localizedDescription)
        }
    }

    private func exportEvents() {
        let panel = NSSavePanel()
        panel.title = "导出自定义日期"
        panel.nameFieldStringValue = "万年历自定义日期.json"
        panel.allowedContentTypes = [.json]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.exportCustomEvents(to: url)
        } catch {
            showMessage("无法导出", error.localizedDescription)
        }
    }

    private func showMessage(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}

private struct EventRow: View {
    let event: CustomEvent

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.highlight ? Palette.red : Color.secondary.opacity(0.5))
                .frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 1) {
                Text(event.name.isEmpty ? "（未命名）" : event.name)
                    .lineLimit(1)
                Text(event.rule.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// 编辑一个自定义日期。
/// 修改先保存在草稿中，停止输入 0.4 秒后（或者关闭编辑器时）才写入文件，避免每输入一个字都保存一次
private struct EventEditor: View {
    let save: (CustomEvent) -> Void
    @State private var event: CustomEvent
    @State private var saveTask: Task<Void, Never>?
    @State private var nextOccurrence: String?

    init(event: CustomEvent, save: @escaping (CustomEvent) -> Void) {
        self.save = save
        _event = State(initialValue: event)
    }

    enum Kind: String, CaseIterable, Identifiable {
        case lunar, solar, weekday, once
        var id: String { rawValue }
        var title: String {
            switch self {
            case .lunar: return "每年农历"
            case .solar: return "每年公历"
            case .weekday: return "每年某月第几个星期几"
            case .once: return "某一天（只有一次）"
            }
        }
    }

    private static let lunarMonths = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"]
    private static let nthTitles = [(1, "第一个"), (2, "第二个"), (3, "第三个"), (4, "第四个"), (5, "第五个"), (-1, "最后一个")]

    var body: some View {
        Form {
            TextField("名称", text: $event.name)
            Picker("类型", selection: kindBinding) {
                ForEach(Kind.allCases) { Text($0.title).tag($0) }
            }
            ruleFields
            Toggle("红色醒目显示", isOn: $event.highlight)
            LabeledContent("日期") { Text(event.rule.description).foregroundStyle(.secondary) }
            if let next = nextOccurrence {
                LabeledContent("下一次") { Text(next).foregroundStyle(.secondary) }
            }
        }
        .formStyle(.grouped)
        .onChange(of: event) { _ in scheduleSave() }
        .onDisappear { flush() }
        // 只在日期规则变化时重新计算"下一次"
        .task(id: event.rule) { nextOccurrence = Self.nextOccurrence(of: event.rule) }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            save(event)
        }
    }

    private func flush() {
        guard let task = saveTask else { return }
        task.cancel()
        saveTask = nil
        save(event)
    }

    @ViewBuilder
    private var ruleFields: some View {
        switch event.rule {
        case let .lunar(m, d):
            Picker("月份", selection: Binding(get: { m }, set: { event.rule = .lunar(month: $0, day: d) })) {
                ForEach(1...12, id: \.self) { Text(Self.lunarMonths[$0 - 1] + "月").tag($0) }
            }
            Picker("日", selection: Binding(get: { d }, set: { event.rule = .lunar(month: m, day: $0) })) {
                ForEach(1...30, id: \.self) { Text(LunarCalendar.dayName($0)).tag($0) }
            }
        case let .solar(m, d):
            Picker("月份", selection: Binding(get: { m }, set: { event.rule = .solar(month: $0, day: min(d, Self.maxDay($0))) })) {
                ForEach(1...12, id: \.self) { Text("\($0)月").tag($0) }
            }
            Picker("日", selection: Binding(get: { d }, set: { event.rule = .solar(month: m, day: $0) })) {
                ForEach(1...Self.maxDay(m), id: \.self) { Text("\($0)日").tag($0) }
            }
        case let .weekday(m, w, n):
            Picker("月份", selection: Binding(get: { m }, set: { event.rule = .weekday(month: $0, weekday: w, nth: n) })) {
                ForEach(1...12, id: \.self) { Text("\($0)月").tag($0) }
            }
            Picker("第几个", selection: Binding(get: { n }, set: { event.rule = .weekday(month: m, weekday: w, nth: $0) })) {
                ForEach(Self.nthTitles, id: \.0) { Text($0.1).tag($0.0) }
            }
            Picker("星期", selection: Binding(get: { w }, set: { event.rule = .weekday(month: m, weekday: $0, nth: n) })) {
                ForEach(0..<7, id: \.self) { Text(LunarCalendar.weekdayName($0)).tag($0) }
            }
        case let .once(y, m, d):
            DatePicker("日期", selection: Binding(
                get: { Calendar.localGregorian.date(from: DateComponents(year: y, month: m, day: d)) ?? Date() },
                set: {
                    let c = Calendar.localGregorian.dateComponents([.year, .month, .day], from: $0)
                    event.rule = .once(year: c.year!, month: c.month!, day: c.day!)
                }), displayedComponents: .date)
            .environment(\.calendar, Calendar.localGregorian)
        case .lunarNewYearsEve:
            EmptyView()
        }
    }

    /// 公历每月最多的天数（2 月允许 29 日）
    private static func maxDay(_ month: Int) -> Int {
        SolarDate.daysInMonth(year: 2000, month: month)
    }

    private var kindBinding: Binding<Kind> {
        Binding(get: {
            switch event.rule {
            case .lunar, .lunarNewYearsEve: return .lunar
            case .solar: return .solar
            case .weekday: return .weekday
            case .once: return .once
            }
        }, set: { kind in
            // 切换类型时，以今天为默认日期
            let today = SolarDate.today
            let lunar = LunarCalendar.lunar(for: today)
            switch kind {
            case .lunar: event.rule = .lunar(month: lunar.month, day: lunar.day)
            case .solar: event.rule = .solar(month: today.month, day: today.day)
            case .weekday: event.rule = .weekday(month: today.month, weekday: today.weekday, nth: (today.day - 1) / 7 + 1)
            case .once: event.rule = .once(year: today.year, month: today.month, day: today.day)
            }
        })
    }

    /// 从今天起的下一次日期（最多查找 2 年）
    private static func nextOccurrence(of rule: DateRule) -> String? {
        let data = CalendarData(holidays: nil, festivals: [], customEvents: [CustomEvent(name: "x", rule: rule)])
        let today = SolarDate.today
        for offset in 0..<(366 * 2) {
            let date = today.adding(days: offset)
            let day = CalendarDay(date: date, data: data)
            if !day.events.isEmpty {
                let suffix = offset == 0 ? "（今天）" : "（\(offset) 天后）"
                return "\(day.solarText) \(day.weekdayName)" + suffix
            }
        }
        return nil
    }
}

@MainActor
final class CustomEventsWindowController: NSWindowController, NSWindowDelegate {
    private var onClose: () -> Void = {}

    convenience init(store: DataStore, onClose: @escaping () -> Void) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 680, height: 440),
                              styleMask: [.titled, .closable, .resizable, .miniaturizable],
                              backing: .buffered, defer: false)
        self.init(window: window)
        self.onClose = onClose
        window.title = "自定义日期"
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentViewController = NSHostingController(rootView: CustomEventsView(store: store))
        window.center()
    }

    func windowWillClose(_ notification: Notification) {
        // 延后释放，避免在窗口关闭过程中销毁自己
        DispatchQueue.main.async { [onClose] in onClose() }
    }
}
