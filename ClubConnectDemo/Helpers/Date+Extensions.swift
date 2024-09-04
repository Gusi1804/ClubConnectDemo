//
//  Date+Extensions.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import Foundation

extension Date {
    /// Get days in the current month
    var daysInMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return []
        }
        return range.compactMap { day -> Date? in
            let dayComponent = DateComponents(year: calendar.component(.year, from: self),
                                              month: calendar.component(.month, from: self),
                                              day: day)
            return calendar.date(from: dayComponent)
        }
    }
    
    var selectedDayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: self)
    }
    
    // Helper to check if a date is today
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    // Helper to get the Month and Year as a String (e.g., "September 2024")
    var monthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    init?(firebaseString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: firebaseString) else { return nil }
        self = date
    }
}
