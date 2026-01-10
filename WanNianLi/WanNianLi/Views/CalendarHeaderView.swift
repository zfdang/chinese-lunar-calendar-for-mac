//
//  CalendarHeaderView.swift
//  WanNianLi
//
//  Navigation header for the calendar
//

import SwiftUI

/// Header view with year/month navigation
struct CalendarHeaderView: View {
    @Binding var displayYear: Int
    @Binding var displayMonth: Int
    let onTodayTapped: () -> Void
    
    private let years = Array(1901...2049)
    private let months = Array(1...12)
    
    var body: some View {
        VStack(spacing: 6) {
            // Lunar year info at top
            Text(lunarYearInfo)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            // Navigation row
            HStack(spacing: 8) {
                // Previous year
                Button(action: previousYear) {
                    Image(systemName: "chevron.left.2")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("上一年")
                
                // Previous month
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("上一月")
                
                Spacer()
                
                // Year picker
                Picker("", selection: $displayYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year) + "年").tag(year)
                    }
                }
                .labelsHidden()
                .frame(width: 85)
                
                // Month picker
                Picker("", selection: $displayMonth) {
                    ForEach(months, id: \.self) { month in
                        Text("\(month)月").tag(month)
                    }
                }
                .labelsHidden()
                .frame(width: 55)
                
                Spacer()
                
                // Next month
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("下一月")
                
                // Next year
                Button(action: nextYear) {
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .help("下一年")
            }
            
            // Today button
            Button(action: onTodayTapped) {
                Text("今天")
                    .font(.system(size: 11))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
    
    // MARK: - Computed Properties
    
    private var lunarYearInfo: String {
        let ganZhi = LunarCalendar.ganZhiYear(displayYear)
        let zodiac = LunarCalendar.zodiac(displayYear)
        return "农历\(ganZhi)年【\(zodiac)】"
    }
    
    // MARK: - Actions
    
    private func previousYear() {
        if displayYear > 1901 {
            displayYear -= 1
        }
    }
    
    private func nextYear() {
        if displayYear < 2049 {
            displayYear += 1
        }
    }
    
    private func previousMonth() {
        if displayMonth > 1 {
            displayMonth -= 1
        } else if displayYear > 1901 {
            displayYear -= 1
            displayMonth = 12
        }
    }
    
    private func nextMonth() {
        if displayMonth < 12 {
            displayMonth += 1
        } else if displayYear < 2049 {
            displayYear += 1
            displayMonth = 1
        }
    }
}

#Preview {
    CalendarHeaderView(
        displayYear: .constant(2024),
        displayMonth: .constant(1),
        onTodayTapped: {}
    )
    .frame(width: 340)
}
