import AppKit
import LunarCore
import SwiftUI

/// 日历使用的颜色，同时适配浅色和深色模式
enum Palette {
    private static func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
        func color(_ hex: UInt32) -> NSColor {
            NSColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
                    blue: CGFloat(hex & 0xff) / 255, alpha: 1)
        }
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? color(dark) : color(light)
        })
    }

    static let bar = dynamic(0xeff8ff, 0x22303d)
    static let red = dynamic(0xff0000, 0xff6259)
    static let blue = dynamic(0x005aff, 0x64a0ff)
    static let highlighted = dynamic(0xffdf9c, 0x6e5522)
    static let hovered = dynamic(0xcdff3f, 0x3f5a17)
    static let lunarText = dynamic(0x555555, 0xb4b4b4)
    static let cardBackground = dynamic(0xfeffcd, 0x3a3a2a)
    static let cardBorder = dynamic(0xdddddf, 0x5a5a4a)
}

struct CalendarView: View {
    @ObservedObject var model: CalendarViewModel
    let menu: AppMenu

    static let cellSize = CGSize(width: 64, height: 48)
    private static let weekdays = Array("日一二三四五六").map(String.init)

    @State private var hovered: Int?
    @State private var pressed: Int?
    @State private var detailShown: Int?

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            weekdayBar
            grid
            navigationBar
        }
        .frame(width: Self.cellSize.width * 7)
        .padding(6)
    }

    // MARK: - 标题

    private var titleBar: some View {
        let title = model.title
        return HStack(spacing: 14) {
            Text(title.solar)
            Text(title.lunar)
        }
        .font(.system(size: 18))
        .frame(maxWidth: .infinity)
        .frame(height: 34)
    }

    private var weekdayBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(Self.weekdays[i])
                    .font(.system(size: 15))
                    .foregroundStyle(i == 0 || i == 6 ? Palette.red : Color.primary)
                    .frame(width: Self.cellSize.width, height: 24)
            }
        }
        .background(Palette.bar)
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
        // 弹出窗口关闭时手势可能被取消而收不到 onEnded，这里清理按下状态
        .onDisappear {
            pressed = nil
            detailShown = nil
            hovered = nil
        }
        .overlay(alignment: .topLeading) {
            if let index = detailShown {
                DetailCard(day: days[index])
                    .position(detailPosition(for: index))
                    .allowsHitTesting(false)
            }
        }
    }

    private func cell(index: Int, day: CalendarDay) -> some View {
        let inMonth = model.grid.isInMonth(day)
        let background: Color = !inMonth ? .clear
            : hovered == index ? Palette.hovered
            : model.isHighlighted(day) ? Palette.highlighted
            : .clear

        return VStack(spacing: 0) {
            Text("\(day.date.day)")
                .font(.system(size: 26))
                .foregroundStyle(day.isRestDay ? Palette.red : Color.primary)
            Text(day.shortText)
                .font(.system(size: 12))
                .foregroundStyle(lunarColor(day))
                .lineLimit(1)
        }
        .frame(width: Self.cellSize.width - 2, height: Self.cellSize.height - 2)
        .background(RoundedRectangle(cornerRadius: 4).fill(background))
        .frame(width: Self.cellSize.width, height: Self.cellSize.height)
        .opacity(inMonth ? 1 : 0.2)
        .contentShape(Rectangle())
        .onHover { inside in
            if inMonth { hovered = inside ? index : (hovered == index ? nil : hovered) }
        }
        .gesture(inMonth ? pressGesture(index: index, day: day) : nil)
    }

    /// 单击选中日期；按住不放时显示详细信息
    private func pressGesture(index: Int, day: CalendarDay) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard pressed != index else { return }
                pressed = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if pressed == index { detailShown = index }
                }
            }
            .onEnded { value in
                pressed = nil
                detailShown = nil
                let size = Self.cellSize
                if CGRect(origin: .zero, size: size).contains(value.location) {
                    model.select(day)
                }
            }
    }

    private func lunarColor(_ day: CalendarDay) -> Color {
        if !day.lunarFestival.isEmpty || day.adjustment == "+" { return Palette.red }
        if !day.solarTerm.isEmpty { return Palette.blue }
        return Palette.lunarText
    }

    /// 详细信息卡片的位置：尽量显示在日期格下方，靠下的行显示在上方
    private func detailPosition(for index: Int) -> CGPoint {
        let (row, col) = (index / 7, index % 7)
        let size = Self.cellSize
        let halfWidth = DetailCard.width / 2 + 2
        let x = min(max((CGFloat(col) + 0.5) * size.width, halfWidth), size.width * 7 - halfWidth)
        let y = row < 3
            ? CGFloat(row + 1) * size.height + DetailCard.height / 2
            : CGFloat(row) * size.height - DetailCard.height / 2
        return CGPoint(x: x, y: y)
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
        .padding(.horizontal, 4)
        .frame(height: 30)
        .background(Palette.bar)
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

/// 按住日期格时显示的详细信息
struct DetailCard: View {
    let day: CalendarDay
    static let width: CGFloat = 132
    static let height: CGFloat = 96

    var body: some View {
        VStack(spacing: 2) {
            Text(day.solarText)
            Text(day.weekdayName)
            Text("\(day.lunarMonthName)月\(day.lunarDayName)").bold()
            Text("\(day.ganZhiYearByLiChun)年 \(day.ganZhiMonth)月 \(day.ganZhiDay)日")
            if !day.allEvents.isEmpty {
                Text(day.allEvents).bold().foregroundStyle(Palette.red)
            }
        }
        .font(.system(size: 12))
        .multilineTextAlignment(.center)
        .padding(6)
        .frame(width: Self.width)
        .frame(minHeight: Self.height)
        .fixedSize(horizontal: false, vertical: true)
        .background(RoundedRectangle(cornerRadius: 6).fill(Palette.cardBackground))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Palette.cardBorder))
        .shadow(radius: 3, y: 1)
    }
}
