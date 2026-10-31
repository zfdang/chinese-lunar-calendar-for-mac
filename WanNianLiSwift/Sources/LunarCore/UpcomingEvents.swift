import Foundation

/// 日历中即将发生的一个节日、自定义事件或节气。
public struct UpcomingEvent: Identifiable, Hashable, Sendable {
    public var id: String { "\(day.date.key)-\(name)" }
    public let day: CalendarDay
    public let name: String
    public let daysAway: Int

    public init(day: CalendarDay, name: String, daysAway: Int) {
        self.day = day
        self.name = name
        self.daysAway = daysAway
    }
}

public enum UpcomingEvents {
    /// 从指定日期（含当天）开始，按日期和日历中的显示顺序查找。
    public static func find(from start: SolarDate, data: CalendarData,
                            days: Int = 90, limit: Int = 6) -> [UpcomingEvent] {
        guard days > 0, limit > 0 else { return [] }
        var result: [UpcomingEvent] = []
        for offset in 0..<days {
            let date = start.adding(days: offset)
            guard LunarCalendar.supportedYears.contains(date.year) else { break }
            let day = CalendarDay(date: date, data: data)
            for name in day.events.map(\.detailName) + (day.solarTerm.isEmpty ? [] : [day.solarTerm]) {
                result.append(UpcomingEvent(day: day, name: name, daysAway: offset))
                if result.count == limit { return result }
            }
        }
        return result
    }
}
