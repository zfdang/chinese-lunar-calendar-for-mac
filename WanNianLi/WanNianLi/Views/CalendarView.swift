//
//  CalendarView.swift
//  WanNianLi
//
//  Main calendar view with SwiftUI
//

import SwiftUI

/// Main calendar view containing header, grid, and detail panel
struct CalendarView: View {
    @State private var displayYear: Int
    @State private var displayMonth: Int
    @State private var selectedDay: CalendarDay?
    @State private var calendarDays: [CalendarDay] = []
    
    private let weekdayTitles = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    
    init() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        _displayYear = State(initialValue: components.year!)
        _displayMonth = State(initialValue: components.month!)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with navigation
            CalendarHeaderView(
                displayYear: $displayYear,
                displayMonth: $displayMonth,
                onTodayTapped: goToToday
            )
            
            Divider()
            
            // Weekday headers
            weekdayHeader
            
            // Calendar grid (always 6 rows)
            calendarGrid
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            
            Divider()
            
            // Detail panel
            CalendarDetailView(day: selectedDay ?? todayDay)
                .padding(.vertical, 6)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadCalendarDays()
            selectToday()
        }
        .onChange(of: displayYear) { _ in
            loadCalendarDays()
        }
        .onChange(of: displayMonth) { _ in
            loadCalendarDays()
        }
    }
    
    // MARK: - Subviews
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(weekdayTitles[index])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(index == 0 || index == 6 ? .red : .primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, day in
                CalendarDayCell(
                    day: day,
                    isSelected: isSelected(day),
                    onSelect: { selectDay(day) }
                )
                .frame(height: 42)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var todayDay: CalendarDay? {
        calendarDays.first { $0.isToday }
    }
    
    // MARK: - Methods
    
    private func loadCalendarDays() {
        calendarDays = LunarCalendar.monthData(year: displayYear, month: displayMonth)
    }
    
    private func goToToday() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        displayYear = components.year!
        displayMonth = components.month!
        selectToday()
    }
    
    private func selectToday() {
        selectedDay = calendarDays.first { $0.isToday }
    }
    
    private func selectDay(_ day: CalendarDay) {
        selectedDay = day
    }
    
    private func isSelected(_ day: CalendarDay) -> Bool {
        guard let selected = selectedDay else { return false }
        return day.solarYear == selected.solarYear &&
               day.solarMonth == selected.solarMonth &&
               day.solarDay == selected.solarDay
    }
}

#Preview {
    CalendarView()
        .frame(width: 340, height: 400)
}
