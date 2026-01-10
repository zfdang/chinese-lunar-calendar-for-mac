//
//  FestivalData.swift
//  WanNianLi
//
//  Festival data for Chinese calendar
//

import Foundation

/// Festival data for solar, lunar, and week-based holidays
struct FestivalData {
    
    // MARK: - Solar Festivals (by month-day)
    
    private static let solarFestivals: [String: String] = [
        "0101": "元旦",
        "0214": "情人节",
        "0308": "妇女节",
        "0312": "植树节",
        "0315": "消费者权益日",
        "0401": "愚人节",
        "0422": "地球日",
        "0501": "劳动节",
        "0504": "青年节",
        "0512": "护士节",
        "0601": "儿童节",
        "0701": "建党节",
        "0801": "建军节",
        "0910": "教师节",
        "1001": "国庆节",
        "1031": "万圣节",
        "1111": "光棍节",
        "1224": "平安夜",
        "1225": "圣诞节"
    ]
    
    // MARK: - Lunar Festivals (by month-day)
    
    private static let lunarFestivals: [String: String] = [
        "0101": "春节",
        "0115": "元宵节",
        "0202": "龙抬头",
        "0505": "端午节",
        "0707": "七夕节",
        "0715": "中元节",
        "0815": "中秋节",
        "0909": "重阳节",
        "1001": "寒衣节",
        "1015": "下元节",
        "1208": "腊八节",
        "1223": "小年",
        "0100": "除夕"  // Special case: last day of year
    ]
    
    // MARK: - Week-based Festivals
    // Format: MMWWD where MM=month, WW=week number (01-05, 09=last), D=weekday (0=Sun)
    
    private static let weekFestivals: [String: String] = [
        "05020": "母亲节",      // May, 2nd Sunday
        "06030": "父亲节",      // June, 3rd Sunday
        "11044": "感恩节"       // November, 4th Thursday
    ]
    
    // MARK: - Public Methods
    
    /// Get solar festival for a date (nil if none)
    static func solarFestival(month: Int, day: Int) -> String? {
        let key = String(format: "%02d%02d", month, day)
        return solarFestivals[key]
    }
    
    /// Get lunar festival for a date (nil if none)
    static func lunarFestival(month: Int, day: Int, isLeapMonth: Bool) -> String? {
        // No lunar festivals in leap months
        if isLeapMonth { return nil }
        
        let key = String(format: "%02d%02d", month, day)
        return lunarFestivals[key]
    }
    
    /// Check for Chinese New Year's Eve (last day of lunar year)
    /// This needs special handling since it can be 29th or 30th
    static func isChineseNewYearEve(lunarYear: Int, lunarMonth: Int, lunarDay: Int) -> Bool {
        if lunarMonth != 12 { return false }
        let lastDay = LunarCalendar.daysInMonth(year: lunarYear, month: 12)
        return lunarDay == lastDay
    }
    
    /// Get week-based festival (nil if none)
    /// weekday: 0=Sunday, 6=Saturday
    static func weekFestival(month: Int, weekOfMonth: Int, weekday: Int, isLastWeek: Bool) -> String? {
        // Check regular week festivals
        let key = String(format: "%02d%02d%d", month, weekOfMonth, weekday)
        if let festival = weekFestivals[key] {
            return festival
        }
        
        // Check "last week" festivals
        if isLastWeek {
            let lastKey = String(format: "%02d09%d", month, weekday)
            return weekFestivals[lastKey]
        }
        
        return nil
    }
}
