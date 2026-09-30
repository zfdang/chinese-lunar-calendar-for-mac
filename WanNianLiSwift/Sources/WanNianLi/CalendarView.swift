import AppKit
import LunarCore
import SwiftUI

/// 日历使用的颜色，自动适配浅色 / 深色模式
enum Palette {
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        func color(_ hex: UInt32) -> NSColor {
            NSColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
                    blue: CGFloat(hex & 0xff) / 255, alpha: 1)
        }
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? color(dark) : color(light)
        })
    }

    /// 节假日红色：比系统红色柔和，避免刺眼
    static let red = dynamic(light: 0xC4473D, dark: 0xE27D72)
    static let blue = dynamic(light: 0x2F6BC4, dark: 0x74A7E8)
    static let accent = Color.accentColor
    /// 标题栏、详细信息面板等区域的底色
    static let panel = Color.primary.opacity(0.05)
    static let hovered = Color.primary.opacity(0.08)
    static let selected = Color.accentColor.opacity(0.18)
}

struct CalendarView: View {
    @ObservedObject var model: CalendarViewModel
    let menu: AppMenu

    static let cellSize = CGSize(width: 64, height: 50)
    private static let weekdays = Array("日一二三四五六").map(String.init)

    @State private var hovered: Int?

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            weekdayBar
            grid
            DetailPanel(day: model.detailDay)
                .padding(.top, 6)
            Divider()
                .padding(.top, 8)
            navigationBar
        }
        .frame(width: Self.cellSize.width * 7)
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 4)
        .onDisappear { hovered = nil }
    }

    // MARK: - 标题

    private var titleBar: some View {
        let title = model.title
        return HStack(spacing: 12) {
            Text(title.solar)
                .font(.system(size: 17, weight: .semibold))
            Text(title.lunar)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 34)
    }

    private var weekdayBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(Self.weekdays[i])
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(i == 0 || i == 6 ? AnyShapeStyle(Palette.red) : AnyShapeStyle(.secondary))
                    .frame(width: Self.cellSize.width, height: 26)
            }
        }
        .background(RoundedRectangle(cornerRadius: 6).fill(Palette.panel))
        .padding(.bottom, 2)
    }

    // MARK: - 日期格

    private var grid: some View {
        let days = model.grid.days
        return VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        cell(index: row * 7 + col, day: days[row * 7 + col])
                    }
                }
            }
        }
    }

    private func cell(index: Int, day: CalendarDay) -> some View {
        let inMonth = model.grid.isInMonth(day)
        let isToday = inMonth && day.date == model.today
        let isSelected = inMonth && !isToday && model.isHighlighted(day)

        let background: Color = isToday ? Palette.accent
            : isSelected ? Palette.selected
            : (inMonth && hovered == index) ? Palette.hovered
            : .clear

        return VStack(spacing: 1) {
            Text("\(day.date.day)")
                .font(.system(size: 22, weight: isToday ? .semibold : .regular))
                .foregroundStyle(isToday ? AnyShapeStyle(.white) : dayColor(day))
            Text(day.shortText)
                .font(.system(size: 11))
                .foregroundStyle(isToday ? AnyShapeStyle(.white.opacity(0.9)) : lunarColor(day))
                .lineLimit(1)
        }
        .frame(width: Self.cellSize.width - 4, height: Self.cellSize.height - 4)
        .background(RoundedRectangle(cornerRadius: 8).fill(background))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(isSelected ? Palette.accent.opacity(0.7) : .clear))
        .frame(width: Self.cellSize.width, height: Self.cellSize.height)
        .opacity(inMonth ? 1 : 0.3)
        .contentShape(Rectangle())
        .onHover { inside in
            if inMonth { hovered = inside ? index : (hovered == index ? nil : hovered) }
        }
        .onTapGesture {
            if inMonth { model.select(day) }
        }
    }

    private func dayColor(_ day: CalendarDay) -> AnyShapeStyle {
        day.isRestDay ? AnyShapeStyle(Palette.red) : AnyShapeStyle(.primary)
    }

    private func lunarColor(_ day: CalendarDay) -> AnyShapeStyle {
        if !day.lunarFestival.isEmpty || day.adjustment == "+" { return AnyShapeStyle(Palette.red) }
        if !day.solarTerm.isEmpty { return AnyShapeStyle(Palette.blue) }
        return AnyShapeStyle(.secondary)
    }

    // MARK: - 底部导航栏

    private var navigationBar: some View {
        HStack(spacing: 4) {
            menu.button
            Spacer(minLength: 0)
            Picker("", selection: Binding(get: { model.year }, set: { model.setYear($0) })) {
                ForEach(CalendarViewModel.years, id: \.self) { Text(String($0)).tag($0) }
            }
            .labelsHidden()
            .frame(width: 66)
            Text("年")
            Picker("", selection: Binding(get: { model.month }, set: { model.setMonth($0) })) {
                ForEach(1...12, id: \.self) { Text(String($0)).tag($0) }
            }
            .labelsHidden()
            .frame(width: 48)
            Text("月")
            Group {
                navButton("上年", icon: "chevron.backward.2", help: "上一年 (←)") { model.moveYear(by: -1) }
                    .disabled(!model.canMoveBackward)
                navButton("上月", icon: "chevron.backward", help: "上一月 (↑)") { model.moveMonth(by: -1) }
                    .disabled(!model.canMoveBackward)
                navButton("下月", icon: "chevron.forward", trailing: true, help: "下一月 (↓)") { model.moveMonth(by: 1) }
                    .disabled(!model.canMoveForward)
                navButton("下年", icon: "chevron.forward.2", trailing: true, help: "下一年 (→)") { model.moveYear(by: 1) }
                    .disabled(!model.canMoveForward)
                navButton("今日", icon: "arrow.uturn.backward", help: "回到今天 (↵)") { model.showToday() }
            }
        }
        .font(.system(size: 12))
        .controlSize(.small)
        .frame(height: 32)
    }

    private func navButton(_ title: String, icon: String, trailing: Bool = false, help: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 1) {
                if !trailing { Image(systemName: icon) }
                Text(title)
                if trailing { Image(systemName: icon) }
            }
        }
        .fixedSize()
        .help(help)
    }
}

/// 选中日期（默认今天）的详细信息
struct DetailPanel: View {
    let day: CalendarDay

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(day.solarText)  \(day.weekdayName)")
                    .font(.system(size: 13, weight: .semibold))
                Text("农历\(day.lunarMonthName)月\(day.lunarDayName)　\(day.ganZhiYearByLiChun)年 \(day.ganZhiMonth)月 \(day.ganZhiDay)日　属\(day.shengXiao)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 3) {
                if let tag = adjustmentTag {
                    Text(tag.text)
                        .font(.system(size: 11))
                        .foregroundStyle(tag.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(tag.color.opacity(0.15)))
                }
                if !day.allEvents.isEmpty {
                    Text(day.allEvents)
                        .font(.system(size: 12))
                        .foregroundStyle(day.lunarFestival.isEmpty && day.solarFestival.isEmpty
                                         && day.specialEvent.isEmpty ? Palette.blue : Palette.red)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(RoundedRectangle(cornerRadius: 8).fill(Palette.panel))
    }

    /// 调休标记：放假 / 上班
    private var adjustmentTag: (text: String, color: Color)? {
        switch day.adjustment {
        case "+": return ("放假", Palette.red)
        case "-": return ("上班", Color.secondary)
        default: return nil
        }
    }
}
