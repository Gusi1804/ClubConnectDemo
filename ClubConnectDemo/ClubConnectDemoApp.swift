//
//  ClubConnectDemoApp.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import FirebaseCore
import SwiftUI

@main
struct ClubConnectDemoApp: App {
    @State private var calendarVM: CalendarViewModel
    
    init() {
        FirebaseApp.configure()
        self.calendarVM = CalendarViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(calendarVM)
        }
    }
}
