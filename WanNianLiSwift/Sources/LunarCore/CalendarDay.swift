import Foundation

/// 某一天在日历中需要显示的全部信息
public struct CalendarDay: Hashable, Sendable {
    public let date: SolarDate
    public let weekday: Int
    public let lunar: LunarDate

    public let solarTerm: String
    /// 当天的节日和事件（内置节日 + 自定义事件）
    public let events: [DayEvent]
    /// 调休安排，nil 表示没有调整
    public let holiday: HolidayDay?
    /// 日期格中数字下方显示的文字
    public let shortText: String

    public init(date: SolarDate, data: CalendarData) {
        self.date = date
        weekday = date.weekday
        lunar = LunarCalendar.lunar(for: date)
        solarTerm = LunarCalendar.solarTerm(on: date)
        events = data.events(on: date, lunar: lunar)
        holiday = data.holidays[date.key]

        var text = (events.map(\.name) + [solarTerm]).filter { !$0.isEmpty }.joined(separator: " ")
        if text.isEmpty {
            // 没有节日或节气时显示农历日期，初一显示月份
            text = lunar.day == 1
                ? LunarCalendar.monthName(lunar.month, isLeap: lunar.isLeap) + "月"
                : LunarCalendar.dayName(lunar.day)
        }
        shortText = Self.shorten(text)
    }

    /// 最多显示 6 个英文字符或 4 个中文字符，超出部分用 ".." 表示
    static func shorten(_ text: String) -> String {
        let units = Array(text.utf16)
        let maxLength = units.contains { $0 > 0xFF } ? 4 : 6
        guard units.count > maxLength else { return text }
        var cut = maxLength
        if UTF16.isLeadSurrogate(units[cut - 1]) { cut -= 1 }   // 不要截断 emoji 等代理对
        let prefix = String(decoding: units.prefix(cut), as: UTF16.self)
        return prefix.trimmingCharacters(in: .whitespaces) + ".."
    }

    // MARK: - 显示用文字

    public var isWeekend: Bool { weekday == 0 || weekday == 6 }
    /// 调休放假
    public var isOffDay: Bool { holiday?.isOffDay == true }
    /// 调休上班
    public var isMakeupWorkday: Bool { holiday?.isOffDay == false }
    /// 数字显示为红色：调休放假，或者没有调成工作日的周末
    public var isRestDay: Bool { isOffDay || (isWeekend && !isMakeupWorkday) }
    /// 有需要醒目显示的节日或事件
    public var hasHighlightedEvent: Bool { events.contains(where: \.highlight) }
    public var lunarMonthName: String { LunarCalendar.monthName(lunar.month, isLeap: lunar.isLeap) }
    public var lunarDayName: String { LunarCalendar.dayName(lunar.day) }
    /// 年干支，以春节为界（与生肖一致，用于标题）
    public var ganZhiYear: String { LunarCalendar.ganZhi(lunar.yearCycle) }
    /// 年干支，以立春为界（与月干支一致，用于"年 月 日"三柱）
    public var ganZhiYearByLiChun: String { LunarCalendar.ganZhi(LunarCalendar.yearCycleByLiChun(date)) }
    public var ganZhiMonth: String { LunarCalendar.ganZhi(lunar.monthCycle) }
    public var ganZhiDay: String { LunarCalendar.ganZhi(lunar.dayCycle) }
    public var shengXiao: String { LunarCalendar.shengXiao(yearCycle: lunar.yearCycle) }
    public var weekdayName: String { LunarCalendar.weekdayName(weekday) }

    /// 例如 "2026年9月30日"
    public var solarText: String { "\(date.year)年\(date.month)月\(date.day)日" }
    /// 例如 "丙午年[马] 八月十九"
    public var lunarText: String { "\(ganZhiYear)年[\(shengXiao)] \(lunarMonthName)月\(lunarDayName)" }
    /// 当天所有的节日、事件和节气
    public var allEvents: String {
        (events.map(\.name) + [solarTerm]).filter { !$0.isEmpty }.joined(separator: " ")
    }
}

/// 一个月的月历：固定 6 行 × 7 列，从星期日开始
public struct MonthGrid: Sendable {
    public let year: Int
    public let month: Int
    public let days: [CalendarDay]

    public init(year: Int, month: Int, data: CalendarData) {
        self.year = year
        self.month = month
        let first = SolarDate(year: year, month: month, day: 1)
        let start = first.adding(days: -first.weekday)
        days = (0..<42).map { CalendarDay(date: start.adding(days: $0), data: data) }
    }

    public func isInMonth(_ day: CalendarDay) -> Bool {
        day.date.year == year && day.date.month == month
    }
}
