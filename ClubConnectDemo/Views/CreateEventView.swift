//
//  CreateEventView.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(CalendarViewModel.self) private var calendarVM

    @Binding var event: Event
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    var isNewEvent: Bool

    var body: some View {
        Form {
            TextField("Event Name", text: $event.name)
            TextField("Event Location", text: $event.locationDescription)
            TextField("Event Description", text: $event.descriptionString, axis: .vertical)
                .lineLimit(5...10)
            DatePicker("Start Date", selection: $event.startDate)
            DatePicker("End Date", selection: $event.endDate)

            Section {
                Button(action: {
                    Task {
                        if isNewEvent {
                            await calendarVM.addEvent(event)
                        } else {
                            await calendarVM.updateEvent(event)
                        }
                        dismiss()
                    }
                }, label: {
                    Text(isNewEvent ? "Save New Event" : "Update Event")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
            }
            .listRowBackground(Color.clear)
            
        }
    }
}

#Preview {
    struct Preview: View {
        @State var event = Event(id: "", name: "", description: "", locationDescription: "", startTimestamp: .init(date: Date()), endTimestamp: .init(date: Date()))
        var body: some View {
            CreateEventView(event: $event, isNewEvent: true)
                .environment(CalendarViewModel())
        }
    }
    
    return Preview()
    
}
