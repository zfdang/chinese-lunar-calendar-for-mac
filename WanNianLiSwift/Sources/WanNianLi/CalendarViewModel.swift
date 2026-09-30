import Combine
import Foundation
import LunarCore

extension SolarDate {
    /// 本地时区的今天
    static var today: SolarDate {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return SolarDate(year: c.year!, month: c.month!, day: c.day!)
    }
}

/// 日历弹出窗口的状态：当前显示的年月、选中的日期
@MainActor
final class CalendarViewModel: ObservableObject {
    static let years = LunarCalendar.supportedYears

    @Published private(set) var year: Int
    @Published private(set) var month: Int
    @Published private(set) var grid: MonthGrid
    /// 用户点击选中的日期；为 nil 时高亮今天
    @Published private(set) var selected: SolarDate?
    @Published private(set) var today: SolarDate

    private let store: DataStore
    private var cancellable: AnyCancellable?

    init(store: DataStore) {
        self.store = store
        let today = SolarDate.today
        self.today = today
        year = today.year
        month = today.month
        grid = MonthGrid(year: today.year, month: today.month, data: store.data)
        cancellable = store.$data.dropFirst().sink { [weak self] data in
            guard let self else { return }
            self.grid = MonthGrid(year: self.year, month: self.month, data: data)
        }
    }

    // MARK: - 导航

    /// 回到今天，并清除选中的日期
    func showToday() {
        today = .today
        selected = nil
        show(year: today.year, month: today.month)
    }

    /// 跨天时更新"今天"，保留当前显示的月份和选中的日期
    func refreshToday() {
        if today != .today { today = .today }
    }

    func setYear(_ y: Int) { show(year: y, month: month) }
    func setMonth(_ m: Int) { show(year: year, month: m) }

    /// 前后移动若干年；超出范围时返回 false
    @discardableResult
    func moveYear(by delta: Int) -> Bool {
        guard Self.years.contains(year + delta) else { return false }
        show(year: year + delta, month: month)
        return true
    }

    /// 前后移动若干月；超出范围时返回 false
    @discardableResult
    func moveMonth(by delta: Int) -> Bool {
        let index = year * 12 + (month - 1) + delta
        guard Self.years.contains(index / 12) else { return false }
        show(year: index / 12, month: index % 12 + 1)
        return true
    }

    var canMoveBackward: Bool { year * 12 + month > Self.years.lowerBound * 12 + 1 }
    var canMoveForward: Bool { year * 12 + month < Self.years.upperBound * 12 + 12 }

    private func show(year: Int, month: Int) {
        self.year = year
        self.month = month
        grid = MonthGrid(year: year, month: month, data: store.data)
    }

    /// 点击日期：点击今天会清除选中，回到默认状态
    func select(_ day: CalendarDay) {
        selected = day.date == today ? nil : day.date
    }

    // MARK: - 显示

    /// 高亮显示的日期：选中的日期，没有选中时为今天
    func isHighlighted(_ day: CalendarDay) -> Bool {
        day.date == (selected ?? today)
    }

    /// 详细信息面板显示的日期：选中的日期，没有选中时为今天
    var detailDay: CalendarDay {
        let date = selected ?? today
        return grid.days.first { $0.date == date } ?? CalendarDay(date: date, data: store.data)
    }

    /// 标题栏的两部分文字
    var title: (solar: String, lunar: String) {
        let visible = grid.days.filter { grid.isInMonth($0) }
        if let day = visible.first(where: isHighlighted) {
            return (day.solarText, day.lunarText)
        }
        // 当前月份中没有选中的日期或今天，显示月份信息（取 15 日，此时本月的"节"已过）
        let middle = visible[14]
        return ("\(year)年\(month)月", "\(middle.ganZhiYear)年[\(middle.shengXiao)] \(middle.ganZhiMonth)月")
    }
}
