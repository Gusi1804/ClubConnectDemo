//
//  Event.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Event: Identifiable, Codable {
    var id: String = UUID().uuidString
    let name: String
    let description: String
    let locationDescription: String
    let startTimestamp: Timestamp
    let endTimestamp: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case locationDescription
        case startTimestamp
        case endTimestamp
    }
    
    var startDate: Date {
        startTimestamp.dateValue()
    }
    
    var endDate: Date {
        endTimestamp.dateValue()
    }
}
