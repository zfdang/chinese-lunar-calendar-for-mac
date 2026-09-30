import Foundation

/// 日历显示所需的全部数据：调休安排、启用的内置节日、自定义事件
public struct CalendarData: Sendable {
    private struct Entry: Sendable {
        let event: DayEvent
        let group: Int
    }

    /// 调休安排，键为 "yyyyMMdd"
    public private(set) var holidays: [String: HolidayDay] = [:]

    private var once: [String: [Entry]] = [:]        // "yyyyMMdd"
    private var solar: [String: [Entry]] = [:]       // "MMdd"
    private var lunar: [String: [Entry]] = [:]       // "MMdd"
    private var weekday: [String: [Entry]] = [:]     // "MM-w-n"
    private var newYearsEve: [Entry] = []

    public init() {}

    public init(holidays: HolidayData?, festivals: [Festival], customEvents: [CustomEvent]) {
        for day in holidays?.days ?? [] {
            self.holidays[day.date.replacingOccurrences(of: "-", with: "")] = day
        }
        // 内置节日在前，自定义事件在后
        for f in festivals { add(DayEvent(name: f.name, highlight: f.highlight), rule: f.rule) }
        for e in customEvents where !e.name.isEmpty { add(DayEvent(name: e.name, highlight: e.highlight), rule: e.rule) }
    }

    private mutating func add(_ event: DayEvent, rule: DateRule) {
        let entry = Entry(event: event, group: rule.displayGroup)
        switch rule {
        case let .once(y, m, d): once[String(format: "%04d%02d%02d", y, m, d), default: []].append(entry)
        case let .solar(m, d): solar[String(format: "%02d%02d", m, d), default: []].append(entry)
        case let .lunar(m, d): lunar[String(format: "%02d%02d", m, d), default: []].append(entry)
        case let .weekday(m, w, n): weekday["\(m)-\(w)-\(n)", default: []].append(entry)
        case .lunarNewYearsEve: newYearsEve.append(entry)
        }
    }

    /// 某一天的节日和事件，按"一次性事件、农历节日、公历节日"的顺序
    func events(on date: SolarDate, lunar lunarDate: LunarDate) -> [DayEvent] {
        var entries = once[date.key] ?? []
        entries += solar[date.monthDayKey] ?? []

        if !lunarDate.isLeap {
            entries += lunar[String(format: "%02d%02d", lunarDate.month, lunarDate.day)] ?? []
            // 农历三十的事件，在只有 29 天的月份显示在最后一天
            if lunarDate.day == 29, let thirtieth = lunar[String(format: "%02d30", lunarDate.month)],
               LunarCalendar.lunar(for: date.adding(days: 1)).day == 1 {
                entries += thirtieth
            }
        }
        if lunarDate.month == 12, !newYearsEve.isEmpty, LunarCalendar.isLunarNewYearsEve(date) {
            entries += newYearsEve
        }

        let daysInMonth = SolarDate.daysInMonth(year: date.year, month: date.month)
        let nth = (date.day - 1) / 7 + 1
        entries += weekday["\(date.month)-\(date.weekday)-\(nth)"] ?? []
        if date.day + 7 > daysInMonth {
            entries += weekday["\(date.month)-\(date.weekday)--1"] ?? []
        }

        // 稳定排序：同组内保持内置在前、自定义在后
        return entries.enumerated()
            .sorted { ($0.element.group, $0.offset) < ($1.element.group, $1.offset) }
            .map(\.element.event)
    }
}
