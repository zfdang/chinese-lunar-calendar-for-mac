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
        .background(KeyboardHandler(
            onLeft: previousMonth,
            onRight: nextMonth,
            onUp: previousYear,
            onDown: nextYear,
            onReturn: goToToday
        ))
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
    
    // MARK: - Navigation Methods
    
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

// MARK: - Keyboard Handler

/// NSViewRepresentable to handle keyboard events
struct KeyboardHandler: NSViewRepresentable {
    let onLeft: () -> Void
    let onRight: () -> Void
    let onUp: () -> Void
    let onDown: () -> Void
    let onReturn: () -> Void
    
    func makeNSView(context: Context) -> KeyHandlerView {
        let view = KeyHandlerView()
        view.onLeft = onLeft
        view.onRight = onRight
        view.onUp = onUp
        view.onDown = onDown
        view.onReturn = onReturn
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: KeyHandlerView, context: Context) {}
    
    class KeyHandlerView: NSView {
        var onLeft: (() -> Void)?
        var onRight: (() -> Void)?
        var onUp: (() -> Void)?
        var onDown: (() -> Void)?
        var onReturn: (() -> Void)?
        
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 123: onLeft?()    // Left arrow - previous month
            case 124: onRight?()   // Right arrow - next month
            case 125: onDown?()    // Down arrow - next year
            case 126: onUp?()      // Up arrow - previous year
            case 36: onReturn?()   // Return - go to today
            default: super.keyDown(with: event)
            }
        }
    }
}

#Preview {
    CalendarView()
        .frame(width: 340, height: 400)
}
