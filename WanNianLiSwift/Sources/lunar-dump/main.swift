import Foundation
import LunarCore

// 用法:
//   lunar-dump <数据目录> [起始年] [结束年]       每天输出一行（制表符分隔），用于与香港天文台数据、原 calendar.js 对比
//   lunar-dump --selftest                        运行数据解析和节日规则的自检
//   lunar-dump --golden [起始年] [结束年]         输出精简的基准数据（每个农历月的初一、每个节气、每年一天的日干支），
//                                                 用于 scripts/check-golden.sh 检查农历计算是否发生变化（默认 1900–2100）
let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("usage: lunar-dump <data-dir> [from-year] [to-year]\n       lunar-dump --golden [from-year] [to-year]\n".data(using: .utf8)!)
    exit(1)
}
if args[1] == "--selftest" {
    exit(runSelfTests() ? 0 : 1)
}
let golden = args[1] == "--golden"
let from = args.count > 2 ? Int(args[2])! : (golden ? 1900 : 1901)
let to = args.count > 3 ? Int(args[3])! : (golden ? 2100 : 2049)

var output = ""
var date = SolarDate(year: from, month: 1, day: 1)

if golden {
    func iso(_ d: SolarDate) -> String { String(format: "%04d-%02d-%02d", d.year, d.month, d.day) }
    while date.year <= to {
        let d = CalendarDay(date: date, data: CalendarData())
        if date.month == 1 && date.day == 1 {
            output += "D \(iso(date)) \(d.ganZhiDay)\n"
        }
        if d.lunar.day == 1 {
            // 月长：第 30 天是下个月的初一则为 29 天（小月），否则为 30 天（大月）
            let length = LunarCalendar.lunar(for: date.adding(days: 29)).day == 1 ? 29 : 30
            output += "M \(iso(date)) \(d.lunar.month)\(d.lunar.isLeap ? " leap" : "") \(length) \(d.ganZhiYear)\(d.shengXiao)\n"
        }
        if !d.solarTerm.isEmpty {
            output += "T \(iso(date)) \(d.solarTerm) \(d.ganZhiMonth)\n"
        }
        date = date.adding(days: 1)
    }
} else {
    let holidays = HolidayData.load(from: URL(fileURLWithPath: args[1]).appendingPathComponent("holidays.json"))
    let data = CalendarData(holidays: holidays, festivals: Festival.builtin, customEvents: [])
    while date.year <= to {
        let d = CalendarDay(date: date, data: data)
        output += [date.key, String(d.lunar.month), String(d.lunar.day), d.lunar.isLeap ? "1" : "0",
                   d.ganZhiYear, d.ganZhiMonth, d.ganZhiDay, d.shengXiao, d.solarTerm,
                   d.events.map(\.name).joined(separator: " "), d.holiday.map { $0.isOffDay ? "+" : "-" } ?? "",
                   d.holiday?.name ?? "", d.shortText]
            .joined(separator: "\t") + "\n"
        date = date.adding(days: 1)
    }
}
FileHandle.standardOutput.write(output.data(using: .utf8)!)

// MARK: - 自检

func runSelfTests() -> Bool {
    var failures = 0
    func check(_ condition: Bool, _ name: String) {
        print((condition ? "ok   " : "FAIL ") + name)
        if !condition { failures += 1 }
    }
    func events(_ data: CalendarData, _ y: Int, _ m: Int, _ d: Int) -> [String] {
        CalendarDay(date: SolarDate(year: y, month: m, day: d), data: data).events.map(\.name)
    }

    // 自定义事件文件：version 缺省为 1，编码后能解码回来
    let noVersion = try? JSONDecoder().decode(CustomEventsFile.self, from: Data(#"{"events":[]}"#.utf8))
    check(noVersion?.version == 1 && noVersion?.events.isEmpty == true, "custom events file without version")
    let sample = [CustomEvent(name: "妈妈生日", rule: .lunar(month: 8, day: 22), highlight: true),
                  CustomEvent(name: "感恩", rule: .weekday(month: 11, weekday: 4, nth: -1)),
                  CustomEvent(name: "搬家", rule: .once(year: 2026, month: 10, day: 18))]
    let encoded = try! JSONEncoder().encode(CustomEventsFile(events: sample))
    check((try? JSONDecoder().decode(CustomEventsFile.self, from: encoded))?.events == sample, "custom events round trip")

    // 旧版 js：字符串中的 "}"、注释掉的条目、内置节日不重复导入
    let js = """
    var SOLARFESTIVAL = {
        "0101": "元旦",
        // "0202": "世界湿地日",
        "0722": "括号}生日",
    };
    var LUNARFESTIVAL = { "0707": "情人节", "0822": "妈妈生日" };
    """
    let imported = LegacyImporter.customEvents(festivalsJS: js, eventsJS: "")
    check(imported.map(\.name) == ["括号}生日", "妈妈生日"], "legacy import (brace in string, comments, built-ins)")
    check(LegacyImporter.recognizes(js) && !LegacyImporter.recognizes("var X = {};"), "legacy file recognition")

    // 节日规则
    let builtin = CalendarData(holidays: nil, festivals: Festival.builtin, customEvents: [])
    check(events(builtin, 2026, 2, 16).contains("除夕") && events(builtin, 2026, 2, 17).contains("春节"), "春节 / 除夕 2026")
    check(events(builtin, 2026, 5, 10).contains("母亲节") && events(builtin, 2026, 11, 26).contains("感恩节"), "母亲节 / 感恩节 2026")
    let custom = CalendarData(holidays: nil, festivals: [], customEvents: sample + [
        CustomEvent(name: "月末", rule: .lunar(month: 12, day: 30)),
    ])
    check(events(custom, 2026, 11, 26) == ["感恩"], "last Thursday of November 2026")
    check(events(custom, 2026, 10, 2) == ["妈妈生日"], "lunar yearly event 2026 (八月廿二 = 10/2)")
    // 2026 年腊月只有 29 天（2027-02-05 是除夕），腊月三十的事件显示在腊月廿九
    check(events(custom, 2027, 2, 5) == ["月末"], "lunar day 30 falls back to day 29")

    // 公历：不受系统日历设置影响
    check(SolarDate(year: 2026, month: 9, day: 30).weekday == 3, "weekday of 2026-09-30")

    print(failures == 0 ? "All self tests passed" : "\(failures) self test(s) failed")
    return failures == 0
}
