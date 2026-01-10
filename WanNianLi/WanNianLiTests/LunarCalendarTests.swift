//
//  LunarCalendarTests.swift
//  WanNianLiTests
//
//  Unit tests for LunarCalendar calculations
//

import XCTest
@testable import WanNianLi

class LunarCalendarTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar(identifier: .gregorian).date(from: components)!
    }
    
    // MARK: - Lunar Date Conversion Tests
    
    func testLunarDate_SpringFestival2024() {
        // 2024-02-10 = 农历甲辰年正月初一
        let result = LunarCalendar.lunarDate(from: date(2024, 2, 10))
        XCTAssertEqual(result.year, 2024)
        XCTAssertEqual(result.month, 1)
        XCTAssertEqual(result.day, 1)
        XCTAssertFalse(result.isLeapMonth)
    }
    
    func testLunarDate_MidAutumn2024() {
        // 2024-09-17 = 农历甲辰年八月十五 (中秋节)
        let result = LunarCalendar.lunarDate(from: date(2024, 9, 17))
        XCTAssertEqual(result.month, 8)
        XCTAssertEqual(result.day, 15)
    }
    
    func testLunarDate_DragonBoat2024() {
        // 2024-06-10 = 农历甲辰年五月初五 (端午节)
        let result = LunarCalendar.lunarDate(from: date(2024, 6, 10))
        XCTAssertEqual(result.month, 5)
        XCTAssertEqual(result.day, 5)
    }
    
    func testLunarDate_LanternFestival2024() {
        // 2024-02-24 = 农历甲辰年正月十五 (元宵节)
        let result = LunarCalendar.lunarDate(from: date(2024, 2, 24))
        XCTAssertEqual(result.month, 1)
        XCTAssertEqual(result.day, 15)
    }
    
    // MARK: - Leap Month Tests
    
    func testLeapMonth_2023HasLeapSecondMonth() {
        // 2023年闰二月
        XCTAssertEqual(LunarCalendar.leapMonth(year: 2023), 2)
    }
    
    func testLeapMonth_2024HasNoLeapMonth() {
        XCTAssertEqual(LunarCalendar.leapMonth(year: 2024), 0)
    }
    
    func testLeapMonth_2020HasLeapFourthMonth() {
        // 2020年闰四月
        XCTAssertEqual(LunarCalendar.leapMonth(year: 2020), 4)
    }
    
    func testLeapMonthDate_2023() {
        // 2023-03-22 to 2023-04-19 is 闰二月
        // 2023-04-01 should be 闰二月
        let result = LunarCalendar.lunarDate(from: date(2023, 4, 1))
        XCTAssertTrue(result.isLeapMonth)
        XCTAssertEqual(result.month, 2)
    }
    
    // MARK: - Solar Term Tests
    
    func testSolarTerm_Lichun2024() {
        // 2024-02-04 = 立春
        let term = LunarCalendar.solarTerm(for: date(2024, 2, 4))
        XCTAssertEqual(term, "立春")
    }
    
    func testSolarTerm_Qingming2024() {
        // 2024-04-04 = 清明
        let term = LunarCalendar.solarTerm(for: date(2024, 4, 4))
        XCTAssertEqual(term, "清明")
    }
    
    func testSolarTerm_Dongzhi2024() {
        // 2024-12-21 = 冬至
        let term = LunarCalendar.solarTerm(for: date(2024, 12, 21))
        XCTAssertEqual(term, "冬至")
    }
    
    func testSolarTerm_Xiazhi2024() {
        // 2024-06-21 = 夏至
        let term = LunarCalendar.solarTerm(for: date(2024, 6, 21))
        XCTAssertEqual(term, "夏至")
    }
    
    func testSolarTerm_NonTermDate() {
        // 2024-02-15 不是节气
        let term = LunarCalendar.solarTerm(for: date(2024, 2, 15))
        XCTAssertNil(term)
    }
    
    // MARK: - Gan-Zhi Tests
    
    func testGanZhiYear() {
        // 2024 = 甲辰年
        XCTAssertEqual(LunarCalendar.ganZhiYear(2024), "甲辰")
        // 2023 = 癸卯年
        XCTAssertEqual(LunarCalendar.ganZhiYear(2023), "癸卯")
        // 2022 = 壬寅年
        XCTAssertEqual(LunarCalendar.ganZhiYear(2022), "壬寅")
    }
    
    func testZodiac() {
        XCTAssertEqual(LunarCalendar.zodiac(2024), "龙")
        XCTAssertEqual(LunarCalendar.zodiac(2023), "兔")
        XCTAssertEqual(LunarCalendar.zodiac(2025), "蛇")
        XCTAssertEqual(LunarCalendar.zodiac(2020), "鼠")
    }
    
    // MARK: - Festival Tests
    
    func testSolarFestival_NewYear() {
        let festival = FestivalData.solarFestival(month: 1, day: 1)
        XCTAssertEqual(festival, "元旦")
    }
    
    func testSolarFestival_NationalDay() {
        let festival = FestivalData.solarFestival(month: 10, day: 1)
        XCTAssertEqual(festival, "国庆节")
    }
    
    func testSolarFestival_LaborDay() {
        let festival = FestivalData.solarFestival(month: 5, day: 1)
        XCTAssertEqual(festival, "劳动节")
    }
    
    func testLunarFestival_SpringFestival() {
        let festival = FestivalData.lunarFestival(month: 1, day: 1, isLeapMonth: false)
        XCTAssertEqual(festival, "春节")
    }
    
    func testLunarFestival_MidAutumn() {
        let festival = FestivalData.lunarFestival(month: 8, day: 15, isLeapMonth: false)
        XCTAssertEqual(festival, "中秋节")
    }
    
    func testLunarFestival_DragonBoat() {
        let festival = FestivalData.lunarFestival(month: 5, day: 5, isLeapMonth: false)
        XCTAssertEqual(festival, "端午节")
    }
    
    func testLunarFestival_LeapMonthNoFestival() {
        // Lunar festivals don't apply in leap months
        let festival = FestivalData.lunarFestival(month: 1, day: 1, isLeapMonth: true)
        XCTAssertNil(festival)
    }
    
    // MARK: - Edge Case Tests
    
    func testBoundaryYear_1901() {
        // 1901-02-19 = 农历辛丑年正月初一
        let result = LunarCalendar.lunarDate(from: date(1901, 2, 19))
        XCTAssertEqual(result.year, 1901)
        XCTAssertEqual(result.month, 1)
        XCTAssertEqual(result.day, 1)
    }
    
    func testBoundaryYear_2049() {
        // 2049-01-21 = 农历戊辰年正月初一
        let result = LunarCalendar.lunarDate(from: date(2049, 1, 21))
        XCTAssertEqual(result.month, 1)
        XCTAssertEqual(result.day, 1)
    }
    
    func testMonthDays_BigMonth() {
        // 大月 30 天
        XCTAssertEqual(LunarCalendar.daysInMonth(year: 2024, month: 1), 30)
    }
    
    func testMonthDays_SmallMonth() {
        // 小月 29 天
        XCTAssertEqual(LunarCalendar.daysInMonth(year: 2024, month: 2), 29)
    }
    
    func testDaysInYear_LeapYear() {
        // 2023 has leap month, should have more days
        let days2023 = LunarCalendar.daysInYear(year: 2023)
        let days2024 = LunarCalendar.daysInYear(year: 2024)
        XCTAssertGreaterThan(days2023, days2024)
    }
    
    // MARK: - Chinese Text Conversion Tests
    
    func testLunarMonthName() {
        XCTAssertEqual(LunarCalendar.monthName(1), "正")
        XCTAssertEqual(LunarCalendar.monthName(12), "腊")
        XCTAssertEqual(LunarCalendar.monthName(6), "六")
    }
    
    func testLunarDayName() {
        XCTAssertEqual(LunarCalendar.dayName(1), "初一")
        XCTAssertEqual(LunarCalendar.dayName(10), "初十")
        XCTAssertEqual(LunarCalendar.dayName(15), "十五")
        XCTAssertEqual(LunarCalendar.dayName(20), "二十")
        XCTAssertEqual(LunarCalendar.dayName(30), "三十")
    }
    
    func testWeekdayName() {
        XCTAssertEqual(LunarCalendar.weekdayName(0), "日")
        XCTAssertEqual(LunarCalendar.weekdayName(1), "一")
        XCTAssertEqual(LunarCalendar.weekdayName(6), "六")
    }
    
    // MARK: - Month Data Generation Tests
    
    func testMonthData_AlwaysReturns42Days() {
        // Calendar should always return 42 days (6 rows × 7 days)
        let data = LunarCalendar.monthData(year: 2024, month: 1)
        XCTAssertEqual(data.count, 42)
    }
    
    func testMonthData_February2024() {
        let data = LunarCalendar.monthData(year: 2024, month: 2)
        XCTAssertEqual(data.count, 42)
        
        // Find February 1st
        let feb1 = data.first { $0.solarMonth == 2 && $0.solarDay == 1 }
        XCTAssertNotNil(feb1)
        XCTAssertEqual(feb1?.weekday, 4) // Thursday
    }
    
    func testMonthData_ContainsToday() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        
        let data = LunarCalendar.monthData(year: components.year!, month: components.month!)
        let todayInData = data.first { $0.isToday }
        XCTAssertNotNil(todayInData)
    }
}
