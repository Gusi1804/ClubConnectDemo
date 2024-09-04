//
//  CalendarViewModel.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

@Observable
class CalendarViewModel {
    var events: [DateRange: [Event]] = [:]
    private let calendar = Calendar.current
    private let db = Firestore.firestore()
    
    func fetchEvents(for dateRange: DateRange) async {
        let start = Timestamp(date: dateRange.start)
        let end = Timestamp(date: dateRange.end)
        
//        print("Fetching events for \(dateRange)")
        
        var events: [Event] = []
        let eventsRef = db.collection("events")
        do {
            let eventsSnapshot = try await eventsRef
                .whereField("startTimestamp", isGreaterThanOrEqualTo: start)
                .whereField("startTimestamp", isLessThan: end)
                .getDocuments()
            for document in eventsSnapshot.documents {
//                print("\(document.documentID) => \(document.data())")
                // Try to decode the document data into the User struct
                do {
                    var event = try document.data(as: Event.self)
//                    print("Event: \(event)")

                    event.id = document.documentID
                    events.append(event)
                } catch let error {
                    print("Error decoding event: \(error)")
                }
            }
        } catch {
            print("Error fetching events: \(error)")
        }
        
        self.events[dateRange] = events
    }
}
