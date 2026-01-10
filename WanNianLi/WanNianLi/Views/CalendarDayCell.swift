//
//  CalendarDayCell.swift
//  WanNianLi
//
//  Individual day cell in the calendar grid
//

import SwiftUI

/// A single day cell in the calendar grid
struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 1) {
                // Solar date number
                Text("\(day.solarDay)")
                    .font(.system(size: 14, weight: day.isToday ? .bold : .medium))
                    .foregroundColor(solarDateColor)
                
                // Lunar date or festival
                Text(day.displayInLunar)
                    .font(.system(size: 9))
                    .foregroundColor(lunarTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .opacity(day.isCurrentMonth ? 1.0 : 0.4)
    }
    
    // MARK: - Colors
    
    private var solarDateColor: Color {
        if isSelected || day.isToday {
            return .white
        }
        // Weekend colors (Sunday=0, Saturday=6)
        if day.weekday == 0 || day.weekday == 6 {
            return .red
        }
        return .primary
    }
    
    private var lunarTextColor: Color {
        if isSelected || day.isToday {
            return .white.opacity(0.9)
        }
        // Lunar festivals in red
        if day.lunarFestival != nil {
            return .red
        }
        // Solar terms in green
        if day.solarTerm != nil {
            return Color(red: 0.2, green: 0.6, blue: 0.2)
        }
        // Solar festivals in blue
        if day.solarFestival != nil {
            return .blue
        }
        return .secondary
    }
    
    private var backgroundColor: Color {
        if day.isToday {
            return .accentColor
        }
        if isSelected {
            return .accentColor.opacity(0.7)
        }
        if isHovered {
            return Color.primary.opacity(0.08)
        }
        return .clear
    }
}

#Preview {
    let day = LunarCalendar.calendarDay(for: Date())
    
    return HStack {
        CalendarDayCell(day: day, isSelected: false, onSelect: {})
            .frame(width: 44, height: 42)
        
        CalendarDayCell(day: day, isSelected: true, onSelect: {})
            .frame(width: 44, height: 42)
    }
    .padding()
}
