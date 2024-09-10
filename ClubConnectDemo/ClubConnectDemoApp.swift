//
//  ClubConnectDemoApp.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import FirebaseCore
import SwiftData
import SwiftUI

@main
struct ClubConnectDemoApp: App {
    @State private var calendarVM: CalendarViewModel
    private let container: ModelContainer
    
    init() {
        FirebaseApp.configure()
        do {
            container = try ModelContainer(for: Event.self)
        } catch {
            fatalError("Failed to create ModelContainer for Event.")
        }
        self.calendarVM = CalendarViewModel(container: container)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(calendarVM)
                .modelContainer(for: [
                    Event.self
                ])
        }
    }
}
