/// 可选的国外公共假日日历。英国按地区划分，其余只包含全国范围的公共假日。
public enum FestivalCalendar: String, Codable, CaseIterable, Identifiable, Sendable {
    case england = "GB-ENG"
    case wales = "GB-WLS"
    case scotland = "GB-SCT"
    case northernIreland = "GB-NIR"
    case unitedStates = "US"
    case france = "FR"
    case germany = "DE"

    public var id: String { rawValue }
    public var isBritish: Bool { rawValue.hasPrefix("GB-") }
    public var countryTitle: String {
        switch self {
        case .england, .wales, .scotland, .northernIreland: return "英国"
        case .unitedStates: return "美国"
        case .france: return "法国"
        case .germany: return "德国"
        }
    }
    public var title: String {
        switch self {
        case .england: return "英格兰"
        case .wales: return "威尔士"
        case .scotland: return "苏格兰"
        case .northernIreland: return "北爱尔兰"
        case .unitedStates: return "美国（联邦）"
        case .france: return "法国（全国）"
        case .germany: return "德国（全国）"
        }
    }
}

/// 第三方数据在维护时生成并随程序打包；运行不依赖网络或 Python。
public enum FestivalCatalog {
    public static let sourceVersion = GeneratedFestivalData.sourceVersion
    public static let sourceURL = "https://github.com/vacanza/holidays/tree/v\(sourceVersion)"

    static let common: [Festival] = decode(GeneratedFestivalData.common, highlight: true) + [
        // python-holidays 不收录愚人节，使用美国国会图书馆的日期资料补充。
        Festival("愚人节", .solar(month: 4, day: 1), .western,
                 sourceURL: "https://blogs.loc.gov/folklife/2016/03/april-fools/")
    ]

    private static let countries: [FestivalCalendar: [Festival]] = Dictionary(uniqueKeysWithValues:
        FestivalCalendar.allCases.map { ($0, decode(GeneratedFestivalData.countries[$0]!, calendar: $0)) })

    public static func festivals(for calendar: FestivalCalendar) -> [Festival] {
        countries[calendar] ?? []
    }

    public static func selected(hiddenCategories: Set<FestivalCategory>,
                                calendars: Set<FestivalCalendar>) -> [Festival] {
        Festival.builtin.filter { !hiddenCategories.contains($0.category) }
            + FestivalCalendar.allCases.filter { calendars.contains($0) }.flatMap { festivals(for: $0) }
    }

    /// 生成格式：每行一年，yyyy|MMdd:名称索引,MMdd:名称索引…。
    private static func decode(_ text: String, highlight: Bool = false, calendar: FestivalCalendar? = nil) -> [Festival] {
        var result: [Festival] = []
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: "|")
            precondition(parts.count == 2, "Invalid generated festival year")
            let year = Int(parts[0])!
            for item in parts[1].split(separator: ",") {
                let fields = item.split(separator: ":")
                precondition(fields.count == 2 && fields[0].count == 4, "Invalid generated festival date")
                let name = GeneratedFestivalData.names[Int(fields[1])!]
                let rule = DateRule.once(year: year, month: Int(fields[0].prefix(2))!, day: Int(fields[0].suffix(2))!)
                precondition(rule.isValid, "Invalid generated festival rule")
                result.append(Festival(name, rule, .western,
                                       highlight: highlight && ["母亲节", "父亲节", "感恩节"].contains(name),
                                       sourceURL: sourceURL, calendar: calendar))
            }
        }
        return result
    }
}
