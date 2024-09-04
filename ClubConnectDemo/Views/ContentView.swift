//
//  ContentView.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    var body: some View {
        NavigationStack {
            MonthView(date: $date)
        }
    }
}

#Preview {
    ContentView()
        .environment(CalendarViewModel())
}
