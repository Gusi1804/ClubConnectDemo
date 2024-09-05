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
    private var lastUpdated: Date?
    
    func fetchEvents(for dateRange: DateRange) async {
        let start = Timestamp(date: dateRange.start)
        let end = Timestamp(date: dateRange.end)
                
        var events: [Event] = []
        let eventsRef = db.collection("events")
        do {
            var eventsSnapshot: QuerySnapshot
            if let lastUpdated {
                eventsSnapshot = try await eventsRef
                    .whereField("startTimestamp", isGreaterThanOrEqualTo: start)
                    .whereField("startTimestamp", isLessThan: end)
                    .whereField("lastModified", isGreaterThan: Timestamp(date: lastUpdated))
                    .getDocuments()
            } else {
                eventsSnapshot = try await eventsRef
                    .whereField("startTimestamp", isGreaterThanOrEqualTo: start)
                    .whereField("startTimestamp", isLessThan: end)
                    .getDocuments()
            }
            for document in eventsSnapshot.documents {
                // Try to decode the document data into the Event struct
                print("FETCHING: \(document.documentID)")
                do {
                    var event = try document.data(as: Event.self)
                    event.id = document.documentID
                    events.append(event)
                } catch let error {
                    print("Error decoding event: \(error)")
                }
            }
            lastUpdated = Date()
        } catch {
            print("Error fetching events: \(error)")
        }
        
//        self.events[dateRange] = events
        updateEvents(dateRange: dateRange, newEvents: events)
    }
    
    func addEvent(_ event: Event) async {
        var newEvent: DocumentReference
        do {
            newEvent = try db.collection("events").addDocument(from: event)
            guard let dateRange = DateRange(date: event.startDate), var events = events[dateRange] else {
                return
            }
            events.append(event)
        } catch let error {
            print("Error writing event to Firestore: \(error)")
            return
        }
        
        do {
            try await newEvent.updateData([
                Event.CodingKeys.lastModified.rawValue: FieldValue.serverTimestamp(),
            ])
            print("Document successfully updated")
        } catch {
            print("Error adding lastModified field: \(error)")
        }
    }
    
    func updateEvent(_ event: Event) async {
        do {
            try db.collection("events").document(event.id).setData(from: event)
            print("Event successfully updated")
        } catch {
            print("Error updating event: \(error)")
        }
        
        do {
            try await db.collection("events").document(event.id).updateData([
                Event.CodingKeys.lastModified.rawValue: FieldValue.serverTimestamp(),
            ])
            print("Document successfully updated")
        } catch {
            print("Error adding lastModified field: \(error)")
        }
    }
    
    private func updateEvents(dateRange: DateRange, newEvents: [Event]) {
        guard var currentEvents = events[dateRange] else {
            // if we haven't fetched the current month ("dateRange"), set it in our dictionary
            self.events[dateRange] = newEvents
            return
        }
        
        for event in newEvents {
            if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
                // if event already exists, update it
                events[dateRange]?[index] = event
            } else {
                // if it's a new event, add it
                events[dateRange]?.append(event)
            }
        }
        
    }
}
