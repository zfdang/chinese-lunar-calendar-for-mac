//
//  LunarCalendar.swift
//  WanNianLi
//
//  Lunar calendar calculations ported from calendar.js
//

import Foundation

// MARK: - Data Structures

/// Represents a lunar date with year, month, day, and leap month flag
struct LunarDate {
    let year: Int
    let month: Int
    let day: Int
    let isLeapMonth: Bool
    
    /// Cycle index for Gan-Zhi year (干支年)
    let yearCycle: Int
    /// Cycle index for Gan-Zhi month (干支月)
    let monthCycle: Int
    /// Cycle index for Gan-Zhi day (干支日)
    let dayCycle: Int
}

/// Represents a calendar day with all calculated information
struct CalendarDay {
    // Solar date
    let solarDate: Date
    let solarYear: Int
    let solarMonth: Int
    let solarDay: Int
    let weekday: Int  // 0=Sunday, 6=Saturday
    
    // Lunar date
    let lunarDate: LunarDate
    
    // Display strings
    let ganZhiYear: String
    let ganZhiMonth: String
    let ganZhiDay: String
    let zodiac: String
    let lunarMonthName: String
    let lunarDayName: String
    
    // Festivals and solar terms
    let solarTerm: String?
    let solarFestival: String?
    let lunarFestival: String?
    
    // State flags
    var isToday: Bool = false
    var isCurrentMonth: Bool = true
    var isSelected: Bool = false
    
    /// What to display in the lunar date area
    var displayInLunar: String {
        // Priority: festival > solar term > lunar date
        if let festival = lunarFestival, !festival.isEmpty {
            return truncate(festival, maxLength: 4)
        }
        if let festival = solarFestival, !festival.isEmpty {
            return truncate(festival, maxLength: 4)
        }
        if let term = solarTerm, !term.isEmpty {
            return term
        }
        // Show month name on first day, otherwise show day name
        if lunarDate.day == 1 {
            return lunarMonthName + "月"
        }
        return lunarDayName
    }
    
    private func truncate(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        return String(text.prefix(maxLength)) + ".."
    }
}

// MARK: - LunarCalendar

/// Main lunar calendar calculation class
struct LunarCalendar {
    
    // MARK: - Constants
    
    private static let tianGan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let diZhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let shengXiao = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    private static let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    private static let lunarMonths = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"]
    private static let lunarDayPrefixes = ["初", "十", "廿", "卅"]
    private static let lunarDayNumbers = ["日", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
    
    private static let solarTermNames = [
        "小寒", "大寒", "立春", "雨水", "惊蛰", "春分",
        "清明", "谷雨", "立夏", "小满", "芒种", "夏至",
        "小暑", "大暑", "立秋", "处暑", "白露", "秋分",
        "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
    ]
    
    // Lunar calendar data for years 1900-2049
    // Format: each entry encodes leap month info and days per month
    private static let lunarInfo: [Int] = [
        0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
        0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
        0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
        0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
        0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
        0x06ca0,0x0b550,0x15355,0x04da0,0x0a5d0,0x14573,0x052d0,0x0a9a8,0x0e950,0x06aa0,
        0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
        0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b5a0,0x195a6,
        0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
        0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
        0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
        0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
        0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
        0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
        0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0
    ]
    
    // Solar term calculation data for 1900-2100
    private static let solarTermInfo: [String] = [
        "9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e","97bcf97c3598082c95f8c965cc920f",
        "97bd0b06bdb0722c965ce1cfcc920f","b027097bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
        "97bcf97c359801ec95f8c965cc920f","97bd0b06bdb0722c965ce1cfcc920f","b027097bd097c36b0b6fc9274c91aa",
        "97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f","97bd0b06bdb0722c965ce1cfcc920f",
        "b027097bd097c36b0b6fc9274c91aa","9778397bd19801ec9210c965cc920e","97b6b97bd19801ec95f8c965cc920f",
        "97bd09801d98082c95f8e1cfcc920f","97bd097bd097c36b0b6fc9210c8dc2","9778397bd197c36c9210c9274c91aa",
        "97b6b97bd19801ec95f8c965cc920e","97bd09801d98082c95f8e1cfcc920f","97bd097bd097c36b0b6fc9210c8dc2",
        "9778397bd097c36c9210c9274c91aa","97b6b97bd19801ec95f8c965cc920e","97bcf97c3598082c95f8e1cfcc920f",
        "97bd097bd097c36b0b6fc9210c8dc2","9778397bd097c36c9210c9274c91aa","97b6b97bd19801ec9210c965cc920e",
        "97bcf97c3598082c95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
        "97b6b97bd19801ec9210c965cc920e","97bcf97c3598082c95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722",
        "9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f",
        "97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
        "97bcf97c359801ec95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
        "97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f","97bd097bd07f595b0b6fc920fb0722",
        "9778397bd097c36b0b6fc9210c8dc2","9778397bd19801ec9210c9274c920e","97b6b7f0e47f531b0723b0b6fb0722",
        "7f0e37f5307f595b0b0bc920fb0722","7f0e397bd097c36b0b6fc9210c8dc2","9778397bd097c36b0b70c9274c91aa",
        "97b6b7f0e47f531b0723b0b6fb0721","7f0e37f1487f595b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc9210c8dc2",
        "9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721","7f0e27f1487f595b0b0bb0b6fb0722",
        "7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721",
        "7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
        "97b6b7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722",
        "9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
        "7f0e397bd07f595b0b0bc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0787b0721",
        "7f0e27f0e47f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722","9778397bd097c36b0b6fc9210c91aa",
        "97b6b7f0e47f149b0723b0787b0721","7f0e27f0e47f531b0723b0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
        "9778397bd097c36b0b6fc9210c8dc2","977837f0e37f149b0723b0787b0721","7f07e7f0e47f531b0723b0b6fb0722",
        "7f0e37f5307f595b0b0bc920fb0722","7f0e397bd097c35b0b6fc9210c8dc2","977837f0e37f14998082b0787b0721",
        "7f07e7f0e47f531b0723b0b6fb0721","7f0e37f1487f595b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc9210c8dc2",
        "977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
        "7f0e397bd097c35b0b6fc920fb0722","977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
        "7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722","977837f0e37f14998082b0787b06bd",
        "7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
        "977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
        "7f0e397bd07f595b0b0bc920fb0722","977837f0e37f14998082b0787b06bd","7f07e7f0e47f149b0723b0787b0721",
        "7f0e27f0e47f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722","977837f0e37f14998082b0723b06bd",
        "7f07e7f0e37f149b0723b0787b0721","7f0e27f0e47f531b0723b0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
        "977837f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b0721","7f07e7f0e47f531b0723b0b6fb0722",
        "7f0e37f1487f595b0b0bb0b6fb0722","7f0e37f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b0721",
        "7f07e7f0e47f531b0723b0b6fb0722","7f0e37f1487f531b0b0bb0b6fb0722","7f0e37f0e37f14898082b0723b02d5",
        "7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e37f1487f531b0b0bb0b6fb0722",
        "7f0e37f0e37f14898082b072297c35","7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
        "7f0e27f1487f531b0b0bb0b6fb0722","7f0e37f0e37f14898082b072297c35","7ec967f0e37f14998082b0787b06bd",
        "7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e37f0e366aa89801eb072297c35",
        "7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f149b0723b0787b0721","7f0e27f1487f531b0b0bb0b6fb0722",
        "7f0e37f0e366aa89801eb072297c35","7ec967f0e37f14998082b0723b06bd","7f07e7f0e47f149b0723b0787b0721",
        "7f0e27f0e47f531b0723b0b6fb0722","7f0e37f0e366aa89801eb072297c35","7ec967f0e37f14998082b0723b06bd",
        "7f07e7f0e37f14998083b0787b0721","7f0e27f0e47f531b0723b0b6fb0722","7f0e37f0e366aa89801eb072297c35",
        "7ec967f0e37f14898082b0723b02d5","7f07e7f0e37f14998082b0787b0721","7f07e7f0e47f531b0723b0b6fb0722",
        "7f0e36665b66aa89801e9808297c35","665f67f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b0721",
        "7f07e7f0e47f531b0723b0b6fb0722","7f0e36665b66a449801e9808297c35","665f67f0e37f14898082b0723b02d5",
        "7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e36665b66a449801e9808297c35",
        "665f67f0e37f14898082b072297c35","7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
        "7f0e26665b66a449801e9808297c35","665f67f0e37f1489801eb072297c35","7ec967f0e37f14998082b0787b06bd",
        "7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722"
    ]
    
    // MARK: - Public Methods
    
    /// Get lunar date from solar date
    static func lunarDate(from date: Date) -> LunarDate {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calculateLunarDate(solarYear: components.year!, solarMonth: components.month!, solarDay: components.day!)
    }
    
    /// Get which month is leap month in a lunar year (0 = no leap month)
    static func leapMonth(year: Int) -> Int {
        guard year >= 1900 && year < 2050 else { return 0 }
        return lunarInfo[year - 1900] & 0xf
    }
    
    /// Get days in a lunar month
    static func daysInMonth(year: Int, month: Int) -> Int {
        guard year >= 1900 && year < 2050 else { return 29 }
        return (lunarInfo[year - 1900] & (0x10000 >> month)) != 0 ? 30 : 29
    }
    
    /// Get days in leap month (0 if no leap month)
    static func daysInLeapMonth(year: Int) -> Int {
        if leapMonth(year: year) == 0 { return 0 }
        return (lunarInfo[year - 1900] & 0x10000) != 0 ? 30 : 29
    }
    
    /// Get total days in a lunar year
    static func daysInYear(year: Int) -> Int {
        guard year >= 1900 && year < 2050 else { return 348 }
        var sum = 348
        var i = 0x8000
        while i > 0x8 {
            if (lunarInfo[year - 1900] & i) != 0 {
                sum += 1
            }
            i >>= 1
        }
        return sum + daysInLeapMonth(year: year)
    }
    
    /// Get Gan-Zhi (干支) string for a year
    static func ganZhiYear(_ year: Int) -> String {
        let cycle = (year - 4) % 60
        return tianGan[cycle % 10] + diZhi[cycle % 12]
    }
    
    /// Get zodiac animal for a year
    static func zodiac(_ year: Int) -> String {
        return shengXiao[(year - 4) % 12]
    }
    
    /// Get lunar month name
    static func monthName(_ month: Int) -> String {
        guard month >= 1 && month <= 12 else { return "" }
        return lunarMonths[month - 1]
    }
    
    /// Get lunar day name (初一, 初二, etc.)
    static func dayName(_ day: Int) -> String {
        guard day >= 1 && day <= 30 else { return "" }
        switch day {
        case 10: return "初十"
        case 20: return "二十"
        case 30: return "三十"
        default:
            let prefix = lunarDayPrefixes[day / 10]
            let suffix = lunarDayNumbers[day % 10]
            return prefix + suffix
        }
    }
    
    /// Get weekday name (日, 一, 二, etc.)
    static func weekdayName(_ weekday: Int) -> String {
        guard weekday >= 0 && weekday <= 6 else { return "" }
        return weekdays[weekday]
    }
    
    /// Get solar term for a date (nil if not a solar term day)
    static func solarTerm(for date: Date) -> String? {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        // Each month has 2 solar terms
        let termIndex1 = (month - 1) * 2  // First term of month
        let termIndex2 = (month - 1) * 2 + 1  // Second term of month
        
        if let termDay1 = getSolarTermDay(year: year, termIndex: termIndex1 + 1), termDay1 == day {
            return solarTermNames[termIndex1]
        }
        if let termDay2 = getSolarTermDay(year: year, termIndex: termIndex2 + 1), termDay2 == day {
            return solarTermNames[termIndex2]
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    /// Calculate lunar date from solar date
    private static func calculateLunarDate(solarYear: Int, solarMonth: Int, solarDay: Int) -> LunarDate {
        // Base date: 1900-01-31 = lunar 1900-01-01
        let calendar = Calendar(identifier: .gregorian)
        var baseComponents = DateComponents()
        baseComponents.year = 1900
        baseComponents.month = 1
        baseComponents.day = 31
        baseComponents.timeZone = TimeZone(identifier: "UTC")
        let baseDate = calendar.date(from: baseComponents)!
        
        var targetComponents = DateComponents()
        targetComponents.year = solarYear
        targetComponents.month = solarMonth
        targetComponents.day = solarDay
        targetComponents.timeZone = TimeZone(identifier: "UTC")
        let targetDate = calendar.date(from: targetComponents)!
        
        var offset = Int(targetDate.timeIntervalSince(baseDate) / 86400)
        
        let dayCycle = offset + 40
        var monthCycle = 14
        
        // Calculate year
        var lunarYear = 1900
        var yearDays = 0
        while lunarYear < 2050 && offset > 0 {
            yearDays = daysInYear(year: lunarYear)
            offset -= yearDays
            monthCycle += 12
            lunarYear += 1
        }
        
        if offset < 0 {
            offset += yearDays
            lunarYear -= 1
            monthCycle -= 12
        }
        
        let yearCycle = lunarYear - 1864
        let leap = leapMonth(year: lunarYear)
        var isLeap = false
        
        // Calculate month
        var lunarMonth = 1
        var monthDays = 0
        while lunarMonth < 13 && offset > 0 {
            // Handle leap month
            if leap > 0 && lunarMonth == (leap + 1) && !isLeap {
                lunarMonth -= 1
                isLeap = true
                monthDays = daysInLeapMonth(year: lunarYear)
            } else {
                monthDays = daysInMonth(year: lunarYear, month: lunarMonth)
            }
            
            // Exit leap month
            if isLeap && lunarMonth == (leap + 1) {
                isLeap = false
            }
            
            offset -= monthDays
            if !isLeap {
                monthCycle += 1
            }
            lunarMonth += 1
        }
        
        // Handle edge case at month boundary
        if offset == 0 && leap > 0 && lunarMonth == leap + 1 {
            if isLeap {
                isLeap = false
            } else {
                isLeap = true
                lunarMonth -= 1
                monthCycle -= 1
            }
        }
        
        if offset < 0 {
            offset += monthDays
            lunarMonth -= 1
            monthCycle -= 1
        }
        
        let lunarDay = offset + 1
        
        return LunarDate(
            year: lunarYear,
            month: lunarMonth,
            day: lunarDay,
            isLeapMonth: isLeap,
            yearCycle: yearCycle,
            monthCycle: monthCycle,
            dayCycle: dayCycle
        )
    }
    
    /// Get Gan-Zhi string from cycle number
    private static func ganZhi(cycle: Int) -> String {
        return tianGan[cycle % 10] + diZhi[cycle % 12]
    }
    
    /// Get the day of month for a solar term
    /// termIndex: 1-24 (1=小寒)
    private static func getSolarTermDay(year: Int, termIndex: Int) -> Int? {
        guard year >= 1900 && year <= 2100 else { return nil }
        guard termIndex >= 1 && termIndex <= 24 else { return nil }
        
        let tableIndex = year - 1900
        guard tableIndex < solarTermInfo.count else { return nil }
        
        let table = solarTermInfo[tableIndex]
        
        // Parse the hex string to get term days
        // Each term is encoded in the string
        let info = [
            parseHex(String(table.prefix(5))),
            parseHex(String(table.dropFirst(5).prefix(5))),
            parseHex(String(table.dropFirst(10).prefix(5))),
            parseHex(String(table.dropFirst(15).prefix(5))),
            parseHex(String(table.dropFirst(20).prefix(5))),
            parseHex(String(table.dropFirst(25).prefix(5)))
        ]
        
        var calDays: [Int] = []
        for i in info {
            let s = String(format: "%05d", i)
            calDays.append(Int(String(s.prefix(1)))!)
            calDays.append(Int(String(s.dropFirst(1).prefix(2)))!)
            calDays.append(Int(String(s.dropFirst(3).prefix(1)))!)
            calDays.append(Int(String(s.suffix(2)))!)
        }
        
        return calDays[termIndex - 1]
    }
    
    private static func parseHex(_ hex: String) -> Int {
        return Int(hex, radix: 16) ?? 0
    }
    
    // MARK: - Calendar Day Generation
    
    /// Generate CalendarDay for a specific date
    static func calendarDay(for date: Date) -> CalendarDay {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        
        let solarYear = components.year!
        let solarMonth = components.month!
        let solarDay = components.day!
        let weekday = components.weekday! - 1  // Convert 1-7 to 0-6
        
        let lunar = lunarDate(from: date)
        
        return CalendarDay(
            solarDate: date,
            solarYear: solarYear,
            solarMonth: solarMonth,
            solarDay: solarDay,
            weekday: weekday,
            lunarDate: lunar,
            ganZhiYear: ganZhiYear(lunar.year),
            ganZhiMonth: ganZhi(cycle: lunar.monthCycle),
            ganZhiDay: ganZhi(cycle: lunar.dayCycle),
            zodiac: zodiac(lunar.year),
            lunarMonthName: (lunar.isLeapMonth ? "闰" : "") + monthName(lunar.month),
            lunarDayName: dayName(lunar.day),
            solarTerm: solarTerm(for: date),
            solarFestival: FestivalData.shared.solarFestival(month: solarMonth, day: solarDay),
            lunarFestival: FestivalData.shared.lunarFestival(month: lunar.month, day: lunar.day, isLeapMonth: lunar.isLeapMonth)
        )
    }
    
    /// Generate calendar data for a month (always 42 days for 6 rows)
    static func monthData(year: Int, month: Int) -> [CalendarDay] {
        let calendar = Calendar(identifier: .gregorian)
        
        // First day of month
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let firstOfMonth = calendar.date(from: components)!
        
        // Get weekday of first day (0=Sunday)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        // Start from the Sunday of the week containing the first day
        let startDate = calendar.date(byAdding: .day, value: -firstWeekday, to: firstOfMonth)!
        
        // Generate 42 days (6 rows × 7 days)
        var days: [CalendarDay] = []
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        for i in 0..<42 {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            var day = calendarDay(for: date)
            
            // Check if this is today
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
            if dayComponents.year == todayComponents.year &&
               dayComponents.month == todayComponents.month &&
               dayComponents.day == todayComponents.day {
                day.isToday = true
            }
            
            // Check if this is in the current display month
            day.isCurrentMonth = (day.solarMonth == month)
            
            days.append(day)
        }
        
        return days
    }
}
