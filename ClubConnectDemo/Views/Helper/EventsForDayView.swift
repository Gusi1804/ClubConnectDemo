//
//  EventsForDayView.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import SwiftUI

struct EventsForDayView: View {
    let date: Date
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Text(date.selectedDayString)
                    .foregroundStyle(.red)
                    .bold()
                ForEach(events, id: \.id) { event in
                    NavigationLink(destination: {
                        EventDetail(event)
                    }, label: {
                        EventRow(event: event)
                    })
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    EventsForDayView(
        date: Date(firebaseString: "September 3, 2024 at 5:00:00 PM UTC-4") ?? Date(),
        events: [Event.example1, Event.example2]
    )
}
