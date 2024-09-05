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
    @EnvironmentObject private var calendarVM: CalendarViewModel
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
//                .animation(.snappy, value: calendarVM.events)
            
            if let selectedDate {
                EventsForDayView(date: selectedDate, events: calendarVM.eventsForDate(selectedDate))
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
        if calendarVM.eventsForDate(date).count > 0 {
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
    
     func fetchEvents() async {
         guard let dateRange = DateRange(date: date) else {
             return
         }
//         print("Fetching events for \(dateRange)")
         await calendarVM.fetchEvents(for: dateRange)
         
         let calendar = Calendar.current
         guard let nextMonthStartDate = calendar.date(byAdding: DateComponents(month: 1), to: date),
               let nextMonthRange = DateRange(date: nextMonthStartDate)
         else { return }
//         print("Fetching events for \(nextMonthRange)")
         await calendarVM.fetchEvents(for: nextMonthRange)
         
         guard let prevMonthStartDate = calendar.date(byAdding: DateComponents(month: -1), to: date),
               let prevMonthRange = DateRange(date: prevMonthStartDate)
         else { return }
//         print("Fetching events for \(prevMonthRange)")
         await calendarVM.fetchEvents(for: prevMonthRange)
    }
}

#Preview {
    MonthView(date: .constant(Date()))
        .environmentObject(CalendarViewModel())
}
