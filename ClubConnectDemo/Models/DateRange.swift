//
//  DateRange.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import Foundation

struct DateRange: Hashable {
    let start: Date
    let end: Date
    
    init?(start: Date, end: Date) {
        let calendar = Calendar.current
        
        self.start = calendar.startOfDay(for: start)
        
        let endDateStartOfDay = calendar.startOfDay(for: end)
        guard let endDateAmended = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: endDateStartOfDay) else { return nil }
        self.end = calendar.startOfDay(for: endDateAmended)
    }
    
    init?(date: Date) {
        // Get the current date
        let currentDate = Date()

        // Create a calendar instance
        let calendar = Calendar.current
        
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else {
            return nil
        }
        
        self.start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        self.end = calendar.date(byAdding: .day, value: range.count - 1, to: self.start)!
    }
    
    var debugDescription: String {
        "\(start) - \(end)"
    }
}
