//
//  CalendarViewModel.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import SwiftData
import SwiftUI

@Observable
class CalendarViewModel {
    var events: [DateRange: [Event]] = [:]
    private let calendar = Calendar.current
    private let db = Firestore.firestore()

    private let container: ModelContainer
    init(container: ModelContainer = try! ModelContainer(for: Event.self)) {
        self.container = container
    }
    
    func fetchEvents(for dateRange: DateRange) async {
        await populateEvents(for: dateRange)
        let start = Timestamp(date: dateRange.start)
        let end = Timestamp(date: dateRange.end)
                
        var events: [Event] = []
        let eventsRef = db.collection("events")
        do {
            var eventsSnapshot: QuerySnapshot
            if let lastUpdatedDate = lastUpdated(for: dateRange) {
                eventsSnapshot = try await eventsRef
                    .whereField("startTimestamp", isGreaterThanOrEqualTo: start)
                    .whereField("startTimestamp", isLessThan: end)
                    .whereField("lastModified", isGreaterThan: Timestamp(date: lastUpdatedDate))
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
                    var firebaseEvent = try document.data(as: FirebaseEvent.self)
                    firebaseEvent.id = document.documentID
                    let event = firebaseEvent.event
                    events.append(event)
                    await saveEvent(event)
                    guard let monthRange = DateRange(date: event.startDate) else {
                        continue
                    }
                    await updateEvents(dateRange: monthRange, newEvent: event)
                } catch let error {
                    print("Error decoding event: \(error)")
                }
            }
            updateLastUpdated(for: dateRange, lastUpdated: Date())
        } catch {
            print("Error fetching events: \(error)")
        }
    }
    
    func addEvent(_ event: Event) async {
        var newEvent: DocumentReference
        do {
            let firebaseEvent = event.firebaseEvent
            newEvent = try db.collection("events").addDocument(from: firebaseEvent)
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
            let firebaseEvent = event.firebaseEvent
            try db.collection("events").document(event.id).setData(from: firebaseEvent)
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
    
    @MainActor
    private func updateEvents(dateRange: DateRange, newEvent: Event) {
        guard let currentEvents = events[dateRange] else {
            // if we haven't fetched the current month ("dateRange"), set it in our dictionary
//            print("No event for \(dateRange.start.formatted(Date.FormatStyle())). Setting event.")
            withAnimation(.snappy) {
                self.events[dateRange] = [newEvent]
            }
            return
        }
        
        if let index = currentEvents.firstIndex(where: { $0.id == newEvent.id }) {
            // if event already exists, update it
//            print("Event already exists. Updating...")
            withAnimation(.snappy) {
                events[dateRange]?[index] = newEvent
            }
        } else {
            // if it's a new event, add it
//            print("Event does not exist. Adding...")
            withAnimation(.snappy) {
                events[dateRange]?.append(newEvent)
            }
        }
    }

    // Helper to get all the events for a date
    func eventsForDate(_ date: Date) -> [Event] {
        guard let range = DateRange(date: date) else { return [] }
        guard let eventsForMonth = events[range] else { return [] }
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
    
    private func lastUpdated(for dateRange: DateRange) -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: dateRange.debugDescription) as? Date
    }
    
    private func updateLastUpdated(for dateRange: DateRange, lastUpdated: Date) {
        let defaults = UserDefaults.standard
        defaults.set(lastUpdated, forKey: dateRange.debugDescription)
    }
    
    @MainActor
    private func populateEvents(for dateRange: DateRange) async {
        let context = container.mainContext
        let eventsDescriptor = FetchDescriptor<Event>(
            predicate: #Predicate {
                $0.startDate >= dateRange.start && $0.startDate <= dateRange.end
            },
            sortBy: [
                .init(\.startDate)
            ]
        )
        
        if let results = try? context.fetch(eventsDescriptor) {
            for event in results {
                guard let monthRange = DateRange(date: event.startDate) else {
                    continue
                }
                updateEvents(dateRange: monthRange, newEvent: event)
            }
        }
    }
    
    @MainActor
    private func saveEvent(_ event: Event) async {
        let context = container.mainContext
        context.insert(event)
    }
}
