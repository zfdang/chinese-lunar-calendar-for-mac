//
//  CalendarDetailView.swift
//  WanNianLi
//
//  Detail panel showing selected date information
//

import SwiftUI

/// Shows detailed information about the selected date
struct CalendarDetailView: View {
    let day: CalendarDay?
    
    var body: some View {
        if let day = day {
            VStack(alignment: .leading, spacing: 4) {
                // Solar date
                HStack(spacing: 6) {
                    Text(String(day.solarYear) + "年" + String(day.solarMonth) + "月" + String(day.solarDay) + "日")
                        .font(.system(size: 12, weight: .medium))
                    
                    Text("星期\(LunarCalendar.weekdayName(day.weekday))")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Lunar date
                HStack(spacing: 6) {
                    Text("农历 \(day.lunarMonthName)月\(day.lunarDayName)")
                        .font(.system(size: 11))
                        .foregroundColor(.purple)
                    
                    if let festival = day.lunarFestival {
                        Text(festival)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
                
                // Gan-Zhi and solar term
                HStack(spacing: 4) {
                    Text("\(day.ganZhiYear)年 \(day.ganZhiMonth)月 \(day.ganZhiDay)日")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    
                    if let term = day.solarTerm {
                        Text(term)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.2))
                    }
                    
                    if let festival = day.solarFestival {
                        Text(festival)
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let day = LunarCalendar.calendarDay(for: Date())
    return CalendarDetailView(day: day)
        .frame(width: 340)
        .padding()
}
