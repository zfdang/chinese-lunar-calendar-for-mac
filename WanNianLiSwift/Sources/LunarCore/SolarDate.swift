/// 公历日期。只做纯日期运算，不涉及时区。
public struct SolarDate: Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int   // 1-12
    public let day: Int     // 1-31

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// 自 1970-01-01 起的天数（Howard Hinnant 的 days_from_civil 算法）
    public var dayNumber: Int {
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yoe = y - era * 400
        let mp = (month + 9) % 12
        let doy = (153 * mp + 2) / 5 + day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        return era * 146097 + doe - 719468
    }

    public init(dayNumber z0: Int) {
        let z = z0 + 719468
        let era = (z >= 0 ? z : z - 146096) / 146097
        let doe = z - era * 146097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        self.init(year: yoe + era * 400 + (m <= 2 ? 1 : 0), month: m, day: d)
    }

    /// 星期几：0 为星期日
    public var weekday: Int {
        let w = (dayNumber + 4) % 7   // 1970-01-01 是星期四
        return w < 0 ? w + 7 : w
    }

    public func adding(days: Int) -> SolarDate {
        SolarDate(dayNumber: dayNumber + days)
    }

    public static func isLeapYear(_ y: Int) -> Bool {
        (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
    }

    public static func daysInMonth(year: Int, month: Int) -> Int {
        [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1]
    }

    public static func < (lhs: SolarDate, rhs: SolarDate) -> Bool {
        lhs.dayNumber < rhs.dayNumber
    }

    /// "yyyyMMdd"
    public var key: String {
        String(format: "%04d%02d%02d", year, month, day)
    }

    /// "MMdd"
    public var monthDayKey: String {
        String(format: "%02d%02d", month, day)
    }
}
