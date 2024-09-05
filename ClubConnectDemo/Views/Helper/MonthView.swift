//
//  MonthView.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import SwiftUI

struct MonthView: View {
    // Current date and calendar
    @Binding var date: Date
    @Environment(CalendarViewModel.self) private var calendarVM
    @State private var selectedDate: Date?
    
    private var calendar = Calendar.current
    
    private var defaultAnimation: Animation {
        .spring(response: 0.5, dampingFraction: 0.8)
    }
    
    init(date: Binding<Date>) {
        _date = date
    }
    
    // Number of columns in the grid
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            headerView
                .padding(.horizontal)
                .task {
                    await fetchEvents()
                }
            
            calendarGrid
                .padding(.horizontal)
                .animation(defaultAnimation, value: date)
            
            if let selectedDate {
                EventsForDayView(date: selectedDate, events: eventsForDate(selectedDate))
                    .animation(defaultAnimation, value: selectedDate)
            } else {
                Spacer()
            }
        }
    }
    
    private var headerView: some View {
        // Display Month and Year
        HStack(alignment: .center) {
            Button(action: {
                guard let new = calendar.date(byAdding: .month, value: -1, to: date) else { return }
                withAnimation(defaultAnimation) {
                    date = new
                }
                Task {
                    await fetchEvents()
                }
            }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            Text(monthYearString())
                .font(.title)
                .padding()
            Spacer()
            Button(action: {
                guard let new = calendar.date(byAdding: .month, value: 1, to: date) else { return }
                withAnimation(defaultAnimation) {
                    date = new
                }
                Task {
                    await fetchEvents()
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var calendarGrid: some View {
        // Grid to display the days
        LazyVGrid(columns: columns, spacing: 15) {
            // Weekday headers
            ForEach(weekdaySymbols(), id: \.self) { weekday in
                Text(weekday)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            
            // Padding for the days before the first day of the month
            ForEach(0..<paddingDaysBeforeFirstDay(), id: \.self) { _ in
                Text("")
                    .frame(width: 40, height: 40)
            }
            
            // Display the days of the current month
            ForEach(date.daysInMonth, id: \.self) { date in
                dayNumberView(date)
            }
        }
    }
    
    @ViewBuilder
    private func dayNumberView(_ date: Date) -> some View {
        if eventsForDate(date).count > 0 {
            Button(action: {
                withAnimation(defaultAnimation) {
                    selectedDate = date
                }
            }, label: {
                Text("\(calendar.component(.day, from: date))")
                    .foregroundStyle(.red)
                    .frame(width: 40, height: 40)
                    .background(date.isToday ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
            })
        } else {
            Text("\(calendar.component(.day, from: date))")
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(date.isToday ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(10)
        }
    }
    
    // Helper to get the weekday symbols (e.g., Sun, Mon, ...)
    private func weekdaySymbols() -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return symbols
    }
    
    // Helper to calculate the number of padding cells for days before the first day of the month
    private func paddingDaysBeforeFirstDay() -> Int {
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return weekday - 1 // Subtract 1 because Sunday is 1
    }
    
    // Helper to get the Month and Year as a String (e.g., "September 2024")
    private func monthYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    // Helper to get all the events for a date
    private func eventsForDate(_ date: Date) -> [Event] {
        guard let range = DateRange(date: Date()) else { return [] }
        guard let eventsForMonth = calendarVM.events[range] else { return [] }
        return eventsForMonth.filter {
            isDateWithinWholeDay(dateToCheck: $0.startDate, referenceDate: date)
        }
    }
    
    // Function to check if a given date is within a specific day
    private func isDateWithinWholeDay(dateToCheck: Date, referenceDate: Date) -> Bool {
        let calendar = Calendar.current
        
        // Get the start of the reference day (00:00:00)
        let startOfDay = calendar.startOfDay(for: referenceDate)
        
        // Get the end of the reference day (23:59:59)
        let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
        
        // Check if the given date falls between start and end of the day
        return dateToCheck >= startOfDay && dateToCheck <= endOfDay
    }
    
     func fetchEvents() async {
        guard let dateRange = DateRange(date: $date.wrappedValue) else {
            return
        }
        await calendarVM.fetchEvents(for: dateRange)
    }
}

#Preview {
    MonthView(date: .constant(Date()))
        .environment(CalendarViewModel())
}
