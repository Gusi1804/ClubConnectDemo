//
//  Event+Extensions.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import Foundation

extension Event {
    var formattedStartTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: self.startDate)
    }
    
    var formattedDurationString: String {
        let duration = self.endDate.timeIntervalSince(self.startDate)
        let formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.maximumUnitCount = 2
            formatter.unitsStyle = .short
            return formatter
        }()
        return formatter.string(from: duration) ?? ""
    }
}
