import Foundation

/// 节日 / 事件的日期规则
public enum DateRule: Codable, Hashable, Sendable {
    /// 某一天（一次性事件）
    case once(year: Int, month: Int, day: Int)
    /// 每年公历某月某日
    case solar(month: Int, day: Int)
    /// 每年农历某月某日（闰月不计；农历三十在只有 29 天的月份显示在最后一天）
    case lunar(month: Int, day: Int)
    /// 每年某月第 nth 个星期几；nth 为 -1 表示最后一个；weekday 0 为星期日
    case weekday(month: Int, weekday: Int, nth: Int)
    /// 除夕（农历年的最后一天）
    case lunarNewYearsEve

    /// 规则的文字描述，例如"每年农历八月廿二"
    public var description: String {
        switch self {
        case let .once(y, m, d):
            return "\(y)年\(m)月\(d)日"
        case let .solar(m, d):
            return "每年\(m)月\(d)日"
        case let .lunar(m, d):
            return "每年农历\(LunarCalendar.monthName(m, isLeap: false))月\(LunarCalendar.dayName(d))"
        case let .weekday(m, w, n):
            let weekday = LunarCalendar.weekdayName(w)
            return n == -1 ? "每年\(m)月最后一个\(weekday)" : "每年\(m)月第\(n)个\(weekday)"
        case .lunarNewYearsEve:
            return "每年除夕"
        }
    }

    /// 显示顺序：一次性事件、农历节日（含星期规则）、公历节日，与旧版一致
    var displayGroup: Int {
        switch self {
        case .once: return 0
        case .lunar, .lunarNewYearsEve, .weekday: return 1
        case .solar: return 2
        }
    }
}

/// 某一天的一个节日或事件
public struct DayEvent: Hashable, Sendable {
    public let name: String
    /// 是否以红色醒目显示
    public let highlight: Bool
}

/// 用户自定义的日期、节日或事件
public struct CustomEvent: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var rule: DateRule
    /// 以红色醒目显示（例如作为节假日）
    public var highlight: Bool

    public init(id: UUID = UUID(), name: String, rule: DateRule, highlight: Bool = false) {
        self.id = id
        self.name = name
        self.rule = rule
        self.highlight = highlight
    }

    /// 名称和规则都相同视为重复（导入时用于去重）
    public func isDuplicate(of other: CustomEvent) -> Bool {
        name == other.name && rule == other.rule
    }
}

/// 自定义事件文件（custom-events.json / 导出文件）的格式
public struct CustomEventsFile: Codable, Sendable {
    public var version = 1
    public var events: [CustomEvent]

    public init(events: [CustomEvent]) {
        self.events = events
    }
}
