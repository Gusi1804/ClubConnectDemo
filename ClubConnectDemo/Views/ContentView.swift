//
//  ContentView.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    @Environment(CalendarViewModel.self) private var calendarVM
    @State private var createdEvent: Event = Event(id: "", name: "", description: "", locationDescription: "", startTimestamp: .init(date: Date()), endTimestamp: .init(date: Date()))

    @State private var presentingAddView = false
    
    var body: some View {
        NavigationStack {
            MonthView(date: $date)
                .navigationTitle("iOS Club: ClubConnect")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("\(Image(systemName: "plus")) New Event") {
                            presentingAddView = true
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Text("\(calendarVM.reads) read(s)")
                    }
                }
            
            NavigationLink(destination: CreateEventView(event: $createdEvent, isNewEvent: true), isActive: $presentingAddView) {
                EmptyView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(CalendarViewModel())
}
