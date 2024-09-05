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
    @StateObject private var calendarVM: CalendarViewModel = CalendarViewModel()
    
    init() {
        FirebaseApp.configure()
//        self.calendarVM = CalendarViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarVM)
        }
    }
}
