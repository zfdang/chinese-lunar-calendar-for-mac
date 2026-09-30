import Foundation
import LunarCore

// 用法: lunar-dump <数据目录> [起始年] [结束年]
// 每天输出一行（制表符分隔），用于与原 calendar.js 的计算结果对比
let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("usage: lunar-dump <data-dir> [from-year] [to-year]\n".data(using: .utf8)!)
    exit(1)
}
let holidays = HolidayData.load(from: URL(fileURLWithPath: args[1]).appendingPathComponent("holidays.json"))
let data = CalendarData(holidays: holidays, festivals: Festival.builtin, customEvents: [])
let from = args.count > 2 ? Int(args[2])! : 1901
let to = args.count > 3 ? Int(args[3])! : 2049

var output = ""
var date = SolarDate(year: from, month: 1, day: 1)
while date.year <= to {
    let d = CalendarDay(date: date, data: data)
    output += [date.key, String(d.lunar.month), String(d.lunar.day), d.lunar.isLeap ? "1" : "0",
               d.ganZhiYear, d.ganZhiMonth, d.ganZhiDay, d.shengXiao, d.solarTerm,
               d.events.map(\.name).joined(separator: " "), d.holiday.map { $0.isOffDay ? "+" : "-" } ?? "",
               d.holiday?.name ?? "", d.shortText]
        .joined(separator: "\t") + "\n"
    date = date.adding(days: 1)
}
FileHandle.standardOutput.write(output.data(using: .utf8)!)
