import Foundation
import LunarCore

extension AppRegressionTests {
    @MainActor
    static func festivalRegressions() throws {
        func data(_ calendars: Set<FestivalCalendar> = [], hidden: Set<FestivalCategory> = [],
                  custom: [CustomEvent] = []) -> CalendarData {
            CalendarData(holidays: nil,
                         festivals: FestivalCatalog.selected(hiddenCategories: hidden, calendars: calendars),
                         customEvents: custom)
        }
        func day(_ data: CalendarData, _ year: Int, _ month: Int, _ day: Int) -> CalendarDay {
            CalendarDay(date: SolarDate(year: year, month: month, day: day), data: data)
        }
        func names(_ data: CalendarData, _ year: Int, _ month: Int, _ date: Int) -> [String] {
            day(data, year, month, date).events.map(\.name)
        }

        check(Festival.builtin.filter { $0.category == .traditional }.count == 8
              && Festival.builtin.filter { $0.category == .publicHoliday }.count == 9,
              "traditional and Chinese solar festival lists are preserved")
        check(Festival.builtin.allSatisfy { $0.rule.isValid }, "default festival rules are valid")
        check(Festival.builtin.filter { ![.traditional, .publicHoliday].contains($0.category) }
            .allSatisfy { $0.sourceURL?.hasPrefix("https://") == true },
              "refactored common festivals and memorials have sources")
        let defaults = data()
        check(names(defaults, 2026, 5, 10).contains("母亲节")
              && names(defaults, 2026, 6, 21).contains("父亲节")
              && names(defaults, 2026, 11, 26).contains("感恩节"),
              "common western dates follow the US reference calendar")
        check(names(defaults, 2026, 4, 1).contains("愚人节"), "April Fools supplement is retained")
        check(!names(defaults, 2026, 7, 4).contains("美国独立日"), "country calendars are opt-in")
        let usa = data([.unitedStates], hidden: [.western])
        check(names(usa, 2026, 7, 4).contains("美国独立日")
              && names(usa, 2026, 7, 3).contains("美国独立日（补假）"),
              "US actual and observed dates are distinct and independent of common festivals")
        check(day(usa, 2026, 7, 4).events.first { $0.name == "美国独立日" }?.detailName == "美国独立日",
              "country labels are not repeated when already part of the festival name")
        check(!day(usa, 2026, 7, 3).isOffDay && !day(usa, 2026, 7, 3).isRestDay,
              "foreign public holidays do not mark Chinese workdays as days off")
        check(names(usa, 2026, 9, 7).contains("美国劳动节")
              && names(usa, 2026, 5, 1).contains("劳动节"),
              "US Labor Day remains distinct from Chinese Labor Day")
        let england = data([.england])
        let scotland = data([.scotland])
        let ireland = data([.northernIreland])
        check(names(england, 2026, 8, 31).contains("夏末银行假日")
              && !names(scotland, 2026, 8, 31).contains("夏末银行假日")
              && names(scotland, 2026, 8, 3).contains("夏季银行假日"),
              "UK summer bank holidays follow the selected region")
        check(names(ireland, 2026, 3, 17).contains("圣帕特里克日")
              && !names(england, 2026, 3, 17).contains("圣帕特里克日"),
              "Northern Ireland holidays do not leak into England")
        check(names(england, 2026, 12, 28).contains("节礼日（补假）"),
              "UK substitute bank holiday is retained")
        check(names(data([.france]), 2026, 7, 14).contains("法国国庆节")
              && names(data([.germany]), 2026, 10, 3).contains("德国统一日"),
              "French and German national dates are loaded")
        check(names(data([.germany]), 2026, 4, 3).contains("耶稣受难日")
              && names(data([.germany]), 2027, 3, 26).contains("耶稣受难日"),
              "Easter-relative festivals vary correctly between years")
        check(names(england, 2022, 9, 19).contains("伊丽莎白二世国葬日")
              && !names(england, 2023, 9, 19).contains("伊丽莎白二世国葬日"),
              "one-off national holidays do not become recurring festivals")
        for calendar in FestivalCalendar.allCases {
            let festivals = FestivalCatalog.festivals(for: calendar)
            check(!festivals.isEmpty && festivals.allSatisfy {
                guard case let .once(year, _, _) = $0.rule else { return false }
                return (1901...2099).contains(year) && $0.rule.isValid
                    && $0.sourceURL == FestivalCatalog.sourceURL && $0.calendar == calendar
            }, "\(calendar.rawValue) snapshot has valid bounded dates and provenance")
        }
        check(names(data([.unitedStates]), 2099, 7, 4).contains("美国独立日")
              && names(data([.france]), 1901, 7, 14).contains("法国国庆节"),
              "snapshot includes the application year boundaries")
        let all = data(Set(FestivalCalendar.allCases), custom: [CustomEvent(name: "圣诞节", rule: .solar(month: 12, day: 25))])
        let christmas = day(all, 2026, 12, 25)
        check(christmas.events.filter { $0.name == "圣诞节" }.count == 2,
              "same-day built-ins merge while same-name personal events remain")
        let shared = christmas.events.first { $0.name == "圣诞节" }!
        check(shared.calendars.count == 7 && shared.detailName == "圣诞节（英国、美国、法国、德国）",
              "merged festival details retain country attribution without duplicate UK labels")
        let upcoming = UpcomingEvents.find(from: SolarDate(year: 2026, month: 12, day: 25),
                                           data: data(Set(FestivalCalendar.allCases)), days: 1)
        check(upcoming.filter { $0.name.hasPrefix("圣诞节") }.count == 1
              && upcoming.contains { $0.name == "圣诞节（英国、美国、法国、德国）" },
              "upcoming events use merged festivals and show their countries")
        check(names(defaults, 2026, 9, 3).contains("抗日战争胜利纪念日")
              && !names(defaults, 2026, 8, 15).contains("抗日战争胜利"),
              "victory memorial uses September 3 instead of August 15")
        check(!names(defaults, 2008, 8, 8).contains("北京奥运会开幕日")
              && !names(defaults, 2015, 9, 3).contains("抗战胜利日假期"),
              "obsolete one-off activities are excluded from memorial calendars")
        check(!names(defaults, 1996, 7, 1).contains("香港回归纪念日")
              && names(defaults, 1997, 7, 1).contains("香港回归纪念日"),
              "memorials are not displayed before their first applicable year")
        check(!names(defaults, 2001, 9, 21).contains("国际和平日")
              && names(defaults, 2002, 9, 21).contains("国际和平日"),
              "September 21 peace observance starts with the 2002 date change")
        check(!names(data(hidden: [.international]), 2026, 3, 15).contains("消费者权益日")
              && names(data(hidden: [.international]), 2026, 3, 5).contains("学雷锋纪念日"),
              "domestic and international memorial switches are independent")
        let legacy = """
        var SOLARFESTIVAL = {"0815":"抗日战争胜利", "0701":"中共诞辰 香港回归"};
        var OTHERFESTIVAL = {"0502":"母亲节"};
        var SPECIFIC_EVENTS = {"20080808":"北京奥运会开幕日", "20150903":"抗战胜利日假期", "20261101":"我的活动"};
        """
        check(LegacyImporter.customEvents(festivalsJS: legacy, eventsJS: legacy).map(\.name) == ["我的活动"],
              "legacy import still excludes removed, renamed, and third-party-replaced defaults")

        let suite = "festival-regressions-" + UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(suite)
        defer { try? FileManager.default.removeItem(at: directory) }
        preferences.set(["western", "memorial"], forKey: "hiddenFestivalCategories")
        preferences.set(["XX"], forKey: "selectedFestivalCalendars")
        let store = DataStore(supportDirectory: directory, defaults: preferences)
        check(store.hiddenCategories == [.western, .memorial, .international] && store.selectedCalendars.isEmpty,
              "migration preserves hidden categories and ignores unknown country codes")
        store.setCategory(.international, visible: true)
        store.setCalendar(.unitedStates, visible: true)
        let reloaded = DataStore(supportDirectory: directory, defaults: preferences)
        check(!reloaded.hiddenCategories.contains(.international) && reloaded.hiddenCategories.contains(.memorial)
              && reloaded.selectedCalendars == [.unitedStates],
              "new preferences survive reload without reapplying the old memorial migration")
        check(names(reloaded.data, 2026, 7, 4).contains("美国独立日"),
              "selected calendar is applied to the reloaded application data")
        reloaded.setCalendar(.unitedStates, visible: false)
        check(!names(reloaded.data, 2026, 7, 4).contains("美国独立日"),
              "disabling a calendar immediately rebuilds the application data")
    }
}
