import Foundation

/// 国务院公布的某一天的放假或调休安排
public struct HolidayDay: Codable, Hashable, Sendable {
    /// "yyyy-MM-dd"
    public let date: String
    /// 所属节日，例如"春节"
    public let name: String
    /// true 为放假，false 为调休上班
    public let isOffDay: Bool

    public init(date: String, name: String, isOffDay: Bool) {
        self.date = date
        self.name = name
        self.isOffDay = isOffDay
    }
}

/// holidays.json 的内容
public struct HolidayData: Codable, Sendable {
    /// 版本号，例如 "20251104"，发布新数据时递增
    public var version: String
    /// 数据来源（国务院通知的网址）
    public var sources: [String]?
    public var days: [HolidayDay]

    public init(version: String, sources: [String]? = nil, days: [HolidayDay]) {
        self.version = version
        self.sources = sources
        self.days = days
    }

    /// 解析 holidays.json；格式不对或没有数据时返回 nil
    public static func decode(_ data: Data) -> HolidayData? {
        guard let decoded = try? JSONDecoder().decode(HolidayData.self, from: data), !decoded.days.isEmpty else {
            return nil
        }
        return decoded
    }

    public static func load(from url: URL) -> HolidayData? {
        (try? Data(contentsOf: url)).flatMap(decode)
    }

    /// 版本号按数字比较
    public func isNewer(than other: HolidayData?) -> Bool {
        guard let other else { return true }
        return version.compare(other.version, options: .numeric) == .orderedDescending
    }
}
