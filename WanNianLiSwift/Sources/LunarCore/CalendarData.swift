import Foundation

/// 节日、调休、个人事件数据。
///
/// 数据仍然保存在原来的 js 文件里（holidays.js / festivals.js / events.js），
/// 这样可以沿用原有的在线更新地址和用户自定义方式。
public struct CalendarData: Sendable {
    /// 阳历节日，键为 "MMdd"
    public var solarFestivals: [String: String] = [:]
    /// 农历节日，键为 "MMdd"，"0100" 表示除夕
    public var lunarFestivals: [String: String] = [:]
    /// 按"某月第几个星期几"定义的节日，键为 "MM" + 星期(0-6) + 第几个(1-5，9 表示最后一个)
    public var weekdayFestivals: [String: String] = [:]
    /// 一次性事件，键为 "yyyyMMdd"
    public var specificEvents: [String: String] = [:]
    /// 国务院公布的调休安排，键为 "yyyyMMdd"，值 "+" 为放假，"-" 为上班
    public var holidayAdjustments: [String: String] = [:]

    public init() {}

    public static let holidaysFile = "holidays.js"
    public static let festivalsFile = "festivals.js"
    public static let eventsFile = "events.js"

    /// 从目录中读取三个 js 数据文件，缺失的文件视为空
    public static func load(from directory: URL) -> CalendarData {
        func read(_ name: String) -> String {
            (try? String(contentsOf: directory.appendingPathComponent(name), encoding: .utf8)) ?? ""
        }
        let festivals = read(festivalsFile)
        var data = CalendarData()
        data.solarFestivals = JSDataParser.object(named: "SOLARFESTIVAL", in: festivals)
        data.lunarFestivals = JSDataParser.object(named: "LUNARFESTIVAL", in: festivals)
        data.weekdayFestivals = JSDataParser.object(named: "OTHERFESTIVAL", in: festivals)
        data.specificEvents = JSDataParser.object(named: "SPECIFIC_EVENTS", in: read(eventsFile))
        data.holidayAdjustments = JSDataParser.object(named: "HOLIDAYADJUSTMENT", in: read(holidaysFile))
        return data
    }
}

/// 解析原 js 数据文件中形如 `var NAME = { "key": "value", ... };` 的对象
public enum JSDataParser {
    public static func object(named name: String, in source: String) -> [String: String] {
        let code = stripComments(source)
        guard let declaration = code.range(of: #"\bvar\s+\#(name)\s*=\s*\{"#, options: .regularExpression),
              let end = code[declaration.upperBound...].firstIndex(of: "}") else {
            return [:]
        }
        let body = String(code[declaration.upperBound..<end])
        let pattern = try! NSRegularExpression(pattern: #"(["'])(.*?)\1\s*:\s*(["'])(.*?)\3"#)
        var result: [String: String] = [:]
        let ns = body as NSString
        for match in pattern.matches(in: body, range: NSRange(location: 0, length: ns.length)) {
            result[ns.substring(with: match.range(at: 2))] = ns.substring(with: match.range(at: 4))
        }
        return result
    }

    /// 读取文件首行中的版本号，如 `// Version: 20251104` → "20251104"；读不到返回 "0"
    public static func version(in source: String) -> String {
        guard let firstLine = source.split(whereSeparator: \.isNewline).first else { return "0" }
        let version = firstLine
            .replacingOccurrences(of: "\u{FEFF}", with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "Version:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return version.isEmpty ? "0" : version
    }

    /// 版本号按数字比较，a 比 b 新时返回 true
    public static func isVersion(_ a: String, newerThan b: String) -> Bool {
        a.compare(b, options: .numeric) == .orderedDescending
    }

    /// 去掉 // 和 /* */ 注释（忽略字符串内部的内容）
    static func stripComments(_ source: String) -> String {
        var output = ""
        var chars = Array(source).makeIterator()
        var quote: Character?
        var pending: Character?
        func next() -> Character? {
            if let p = pending { pending = nil; return p }
            return chars.next()
        }
        while let c = next() {
            if let q = quote {
                output.append(c)
                if c == "\\", let escaped = next() { output.append(escaped) }
                else if c == q || c.isNewline { quote = nil }   // js 字符串不能跨行，避免未闭合的引号影响后面的内容
                continue
            }
            if c == "\"" || c == "'" {
                quote = c
                output.append(c)
            } else if c == "/" {
                let n = next()
                if n == "/" {
                    while let x = next(), !x.isNewline {}
                    output.append("\n")
                } else if n == "*" {
                    var previous: Character = " "
                    while let x = next() {
                        if previous == "*" && x == "/" { break }
                        previous = x
                    }
                } else {
                    output.append(c)
                    pending = n
                }
            } else {
                output.append(c)
            }
        }
        return output
    }
}
