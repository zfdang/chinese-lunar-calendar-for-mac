import Foundation

/// 从旧版的 festivals.js / events.js 中导入用户自己添加的节日和事件
public enum LegacyImporter {
    /// 内置节日在旧版中使用的名称
    private static let legacyNames = ["七夕": "情人节"]

    /// 解析 js 文本，返回其中不属于内置节日的条目
    public static func customEvents(festivalsJS: String, eventsJS: String) -> [CustomEvent] {
        var result: [CustomEvent] = []
        func add(_ name: String, _ rule: DateRule?, highlight: Bool) {
            guard let rule, !name.isEmpty else { return }
            // 与内置节日相同（名称和日期都一样，或者是内置节日的旧名称）的条目不需要导入
            if Festival.builtin.contains(where: { $0.rule == rule && ($0.name == name || legacyNames[$0.name] == name) }) { return }
            let event = CustomEvent(name: name, rule: rule, highlight: highlight)
            if !result.contains(where: { $0.isDuplicate(of: event) }) { result.append(event) }
        }

        // 旧版中阳历节日不标红，农历节日和"第几个星期几"类节日标红
        for (key, name) in JSDataParser.object(named: "SOLARFESTIVAL", in: festivalsJS).sorted(by: { $0.key < $1.key }) {
            add(name, digits(key, 4).map { .solar(month: $0[0], day: $0[1]) }, highlight: false)
        }
        for (key, name) in JSDataParser.object(named: "LUNARFESTIVAL", in: festivalsJS).sorted(by: { $0.key < $1.key }) {
            if key == "0100" {
                add(name, .lunarNewYearsEve, highlight: true)
            } else {
                add(name, digits(key, 4).map { .lunar(month: $0[0], day: $0[1]) }, highlight: true)
            }
        }
        for (key, name) in JSDataParser.object(named: "OTHERFESTIVAL", in: festivalsJS).sorted(by: { $0.key < $1.key }) {
            // "MMwn"：月份、星期(0-6)、第几个(9 表示最后一个)
            guard key.count == 4, let month = Int(key.prefix(2)),
                  let weekday = Int(String(Array(key)[2])), let n = Int(String(Array(key)[3])) else { continue }
            add(name, .weekday(month: month, weekday: weekday, nth: n == 9 ? -1 : n), highlight: true)
        }
        for (key, name) in JSDataParser.object(named: "SPECIFIC_EVENTS", in: eventsJS).sorted(by: { $0.key < $1.key }) {
            guard key.count == 8, let y = Int(key.prefix(4)), let md = digits(String(key.suffix(4)), 4) else { continue }
            add(name, .once(year: y, month: md[0], day: md[1]), highlight: false)
        }
        return result
    }

    /// "MMdd" → [MM, dd]，并检查范围
    private static func digits(_ key: String, _ length: Int) -> [Int]? {
        guard key.count == length, let m = Int(key.prefix(2)), let d = Int(key.suffix(2)),
              (1...12).contains(m), (1...31).contains(d) else { return nil }
        return [m, d]
    }
}

/// 解析旧版 js 数据文件中形如 `var NAME = { "key": "value", ... };` 的对象
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
