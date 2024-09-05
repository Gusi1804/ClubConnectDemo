//
//  Event.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Event: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var locationDescription: String
    var startTimestamp: Timestamp
    var endTimestamp: Timestamp
    var lastModified: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case locationDescription
        case startTimestamp
        case endTimestamp
        case lastModified
    }
    
    var startDate: Date {
        get {
            startTimestamp.dateValue()
        }
        set {
            startTimestamp = .init(date: newValue)
        }
    }
    
    var endDate: Date {
        get {
            endTimestamp.dateValue()
        }
        set {
            endTimestamp = .init(date: newValue)
        }
    }
    
    init(name: String, description: String, locationDescription: String, startTimestamp: Timestamp, endTimestamp: Timestamp, lastModified: Timestamp? = nil) {
        self.name = name
        self.description = description
        self.locationDescription = locationDescription
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        if let lastModified {
            self.lastModified = lastModified
        } else {
            self.lastModified = .init(date: Date())
        }
    }
}
