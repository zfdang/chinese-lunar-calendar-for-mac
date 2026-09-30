/// 内置节日的分类，可以在设置中分别显示或隐藏
public enum FestivalCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case traditional
    case publicHoliday
    case western
    case memorial

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .traditional: return "传统节日"
        case .publicHoliday: return "公历节日"
        case .western: return "西方节日"
        case .memorial: return "纪念日"
        }
    }
}

/// 内置节日
public struct Festival: Hashable, Sendable {
    public let name: String
    public let rule: DateRule
    public let category: FestivalCategory
    /// 以红色醒目显示（旧版中农历节日和"第几个星期几"类节日为红色）
    public let highlight: Bool

    init(_ name: String, _ rule: DateRule, _ category: FestivalCategory, highlight: Bool = false) {
        self.name = name
        self.rule = rule
        self.category = category
        self.highlight = highlight
    }

    /// 内置节日列表（来自旧版 festivals.js / events.js 的默认内容）
    public static let builtin: [Festival] = [
        // 传统节日
        Festival("春节", .lunar(month: 1, day: 1), .traditional, highlight: true),
        Festival("元宵节", .lunar(month: 1, day: 15), .traditional, highlight: true),
        Festival("端午节", .lunar(month: 5, day: 5), .traditional, highlight: true),
        Festival("七夕", .lunar(month: 7, day: 7), .traditional, highlight: true),
        Festival("中秋节", .lunar(month: 8, day: 15), .traditional, highlight: true),
        Festival("重阳节", .lunar(month: 9, day: 9), .traditional, highlight: true),
        Festival("腊八节", .lunar(month: 12, day: 8), .traditional, highlight: true),
        Festival("除夕", .lunarNewYearsEve, .traditional, highlight: true),
        // 公历节日
        Festival("元旦", .solar(month: 1, day: 1), .publicHoliday),
        Festival("妇女节", .solar(month: 3, day: 8), .publicHoliday),
        Festival("植树节", .solar(month: 3, day: 12), .publicHoliday),
        Festival("劳动节", .solar(month: 5, day: 1), .publicHoliday),
        Festival("青年节", .solar(month: 5, day: 4), .publicHoliday),
        Festival("儿童节", .solar(month: 6, day: 1), .publicHoliday),
        Festival("建军节", .solar(month: 8, day: 1), .publicHoliday),
        Festival("中国教师节", .solar(month: 9, day: 10), .publicHoliday),
        Festival("国庆节", .solar(month: 10, day: 1), .publicHoliday),
        // 西方节日
        Festival("情人节", .solar(month: 2, day: 14), .western),
        Festival("愚人节", .solar(month: 4, day: 1), .western),
        Festival("母亲节", .weekday(month: 5, weekday: 0, nth: 2), .western, highlight: true),
        Festival("父亲节", .weekday(month: 6, weekday: 0, nth: 3), .western, highlight: true),
        Festival("万圣节", .solar(month: 10, day: 31), .western),
        Festival("感恩节", .weekday(month: 11, weekday: 4, nth: 4), .western, highlight: true),
        Festival("平安夜", .solar(month: 12, day: 24), .western),
        Festival("圣诞节", .solar(month: 12, day: 25), .western),
        // 纪念日
        Festival("学雷锋纪念日", .solar(month: 3, day: 5), .memorial),
        Festival("消费者权益日", .solar(month: 3, day: 15), .memorial),
        Festival("世界红十字日", .solar(month: 5, day: 8), .memorial),
        Festival("国际禁毒日", .solar(month: 6, day: 26), .memorial),
        Festival("中共诞辰 香港回归", .solar(month: 7, day: 1), .memorial),
        Festival("抗日战争纪念日", .solar(month: 7, day: 7), .memorial),
        Festival("抗日战争胜利", .solar(month: 8, day: 15), .memorial),
        Festival("辛亥革命纪念日", .solar(month: 10, day: 10), .memorial),
        Festival("北京奥运会开幕日", .once(year: 2008, month: 8, day: 8), .memorial),
        Festival("抗战胜利日假期", .once(year: 2015, month: 9, day: 3), .memorial),
    ]
}
