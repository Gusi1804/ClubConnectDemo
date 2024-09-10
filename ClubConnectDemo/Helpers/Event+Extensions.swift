//
//  Event+Extensions.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import FirebaseCore
import FirebaseFirestore
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
    
    static let example1: Event = Event(
        id: UUID().uuidString,
        name: "First Meeting of ClubConnect",
        description: "This is a sample event for previews.",
        locationDescription: "Pettit Conference 102B",
        startTimestamp: Timestamp(date: Date(firebaseString: "September 3, 2024 at 5:00:00 PM UTC-4") ?? Date()),
        endTimestamp: Timestamp(date: Date(firebaseString: "September 3, 2024 at 6:00:00 PM UTC-4") ?? Date()))
    static let example2: Event = Event(
        id: UUID().uuidString,
        name: "Second Meeting of ClubConnect",
        description: "This is a very long description for the second club meeting for ClubConnect. We will be covering the second part of the demo, in particular navigation and Firebase.",
        locationDescription: "Pettit Conference 102B",
        startTimestamp: Timestamp(date: Date(firebaseString: "September 5, 2024 at 5:00:00 PM UTC-4") ?? Date()),
        endTimestamp: Timestamp(date: Date(firebaseString: "September 5, 2024 at 6:00:00 PM UTC-4") ?? Date()))
    static let example3: Event = Event(
        id: UUID().uuidString,
        name: "Another Event",
        description: "This is another event after our meeting",
        locationDescription: "CCB 016",
        startTimestamp: Timestamp(date: Date(firebaseString: "September 3, 2024 at 7:30:00 PM UTC-4") ?? Date()),
        endTimestamp: Timestamp(date: Date(firebaseString: "September 3, 2024 at 8:30:00 PM UTC-4") ?? Date()))
}
