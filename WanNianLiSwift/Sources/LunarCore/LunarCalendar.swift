import Foundation

/// 农历日期及对应的干支序号（干支序号 0 为甲子，取值 0-59）
public struct LunarDate: Hashable, Sendable {
    public let month: Int
    public let day: Int
    public let isLeap: Bool
    public let yearCycle: Int
    public let monthCycle: Int
    public let dayCycle: Int
}

/// 农历计算。
///
/// - 农历年月日、闰月：系统自带的 `Calendar(identifier: .chinese)`（ICU 实现）
/// - 节气：1900-2100 年节气速查表
/// - 年干支：以春节为界；月干支：以"节"（立春、惊蛰……）为界；日干支：按日序推算
public enum LunarCalendar {
    /// 支持的公历年份范围（受节气表限制）
    public static let supportedYears = 1901...2099

    static let tianGan = Array("甲乙丙丁戊己庚辛壬癸")
    static let diZhi = Array("子丑寅卯辰巳午未申酉戌亥")
    static let shengXiao = Array("鼠牛虎兔龙蛇马羊猴鸡狗猪")
    static let chineseDigits = Array("日一二三四五六七八九十")
    static let lunarMonthNames = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"]
    static let lunarDayPrefix = Array("初十廿卅")
    public static let solarTermNames = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
                                        "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑",
                                        "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"]

    // 农历以北京时间为准
    private static let chinaTimeZone = TimeZone(identifier: "Asia/Shanghai")!
    private static let gregorian: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = chinaTimeZone
        return c
    }()
    private static let chinese: Calendar = {
        var c = Calendar(identifier: .chinese)
        c.timeZone = chinaTimeZone
        return c
    }()

    /// 1900-01-31 为甲辰日（干支序号 40）
    private static let dayCycleBase = SolarDate(year: 1900, month: 1, day: 31).dayNumber - 40
    /// 2024 年 2 月（立春之后）为丙寅月（干支序号 2）
    private static let monthCycleBase = 2024 * 12 + 2 - 2

    // MARK: - 公历转农历

    private static func chineseComponents(_ date: SolarDate) -> DateComponents {
        let noon = gregorian.date(from: DateComponents(year: date.year, month: date.month, day: date.day, hour: 12))!
        return chinese.dateComponents([.year, .month, .day], from: noon)
    }

    public static func lunar(for date: SolarDate) -> LunarDate {
        let c = chineseComponents(date)
        // ICU 在个别月份（如 2057 年九月、2097 年七月）会把初一算成第 0 天，
        // 整个月的日期都少 1，与香港天文台的数据对比后在这里修正
        var day = c.day!
        let monthStart = chineseComponents(date.adding(days: -day))
        if monthStart.day == 0 && monthStart.month == c.month && monthStart.isLeapMonth == c.isLeapMonth {
            day += 1
        }

        // 以"节"为界确定月份：本月的节还没到，则仍属上一个节月
        var monthIndex = date.year * 12 + date.month
        if date.day < solarTermDay(year: date.year, index: date.month * 2 - 1) {
            monthIndex -= 1
        }

        return LunarDate(month: c.month!,
                         day: day,
                         isLeap: c.isLeapMonth ?? false,
                         yearCycle: c.year! - 1,
                         monthCycle: mod60(monthIndex - monthCycleBase),
                         dayCycle: mod60(date.dayNumber - dayCycleBase))
    }

    /// 以立春为界的年干支序号（1984 年立春后为甲子年）
    public static func yearCycleByLiChun(_ date: SolarDate) -> Int {
        let beforeLiChun = date.month < 2 || (date.month == 2 && date.day < solarTermDay(year: date.year, index: 3))
        return mod60((beforeLiChun ? date.year - 1 : date.year) - 1984)
    }

    /// 是否为除夕（农历年的最后一天）
    public static func isLunarNewYearsEve(_ date: SolarDate) -> Bool {
        let next = lunar(for: date.adding(days: 1))
        return next.month == 1 && next.day == 1 && !next.isLeap
    }

    // MARK: - 节气

    /// y 年第 n 个节气（1-24，从小寒算起）在公历中的日期；超出范围返回 -1
    public static func solarTermDay(year y: Int, index n: Int) -> Int {
        guard (1900...2100).contains(y), (1...24).contains(n) else { return -1 }
        let table = Array(LunarData.solarTermInfo[y - 1900])
        // 每 5 个十六进制字符转成十进制字符串，再按 1、2、1、2 位拆出 4 个节气日期
        let chunk = (n - 1) / 4
        let hex = String(table[(chunk * 5)..<(chunk * 5 + 5)])
        let decimal = Array(String(Int(hex, radix: 16) ?? 0))
        let ranges = [(0, 1), (1, 2), (3, 1), (4, 2)]
        let (start, length) = ranges[(n - 1) % 4]
        guard start < decimal.count else { return -1 }
        return Int(String(decimal[start..<min(start + length, decimal.count)])) ?? -1
    }

    /// 当天的节气名称，没有则返回 ""
    public static func solarTerm(on date: SolarDate) -> String {
        for n in [date.month * 2 - 1, date.month * 2] where solarTermDay(year: date.year, index: n) == date.day {
            return solarTermNames[n - 1]
        }
        return ""
    }

    // MARK: - 文字

    private static func mod60(_ x: Int) -> Int {
        ((x % 60) + 60) % 60
    }

    public static func ganZhi(_ cycle: Int) -> String {
        let c = mod60(cycle)
        return String(tianGan[c % 10]) + String(diZhi[c % 12])
    }

    public static func shengXiao(yearCycle: Int) -> String {
        String(shengXiao[mod60(yearCycle) % 12])
    }

    public static func monthName(_ month: Int, isLeap: Bool) -> String {
        (isLeap ? "闰" : "") + lunarMonthNames[month - 1]
    }

    public static func dayName(_ day: Int) -> String {
        switch day {
        case 10: return "初十"
        case 20: return "二十"
        case 30: return "三十"
        default: return String(lunarDayPrefix[day / 10]) + String(chineseDigits[day % 10])
        }
    }

    public static func weekdayName(_ weekday: Int) -> String {
        "星期" + String(chineseDigits[weekday])
    }
}
