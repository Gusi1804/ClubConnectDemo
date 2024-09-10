//
//  Event.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 03/09/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import SwiftData

@Model
class Event: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var descriptionString: String
    var locationDescription: String
    var startDate: Date
    var endDate: Date
    var lastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case name
        case descriptionString = "description"
        case locationDescription
        case startDate
        case endDate
        case lastModified
    }
    
    init(id: String?, name: String, description: String, locationDescription: String, startTimestamp: Timestamp, endTimestamp: Timestamp, lastModified: Timestamp? = nil) {
        if let id {
            self.id = id
        }
        self.name = name
        self.descriptionString = description
        self.locationDescription = locationDescription
        self.startDate = startTimestamp.dateValue()
        self.endDate = endTimestamp.dateValue()
        if let lastModified {
            self.lastModified = lastModified.dateValue()
        } else {
            self.lastModified = Date()
        }
    }
    
    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.descriptionString = try values.decodeIfPresent(String.self, forKey: .descriptionString) ?? ""
        self.locationDescription = try values.decodeIfPresent(String.self, forKey: .locationDescription) ?? ""
        self.startDate = try values.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.endDate = try values.decodeIfPresent(Date.self, forKey: .endDate) ?? Date()
        self.lastModified = try values.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(descriptionString, forKey: .descriptionString)
        try container.encode(locationDescription, forKey: .locationDescription)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(lastModified, forKey: .lastModified)
    }
}

extension Event {
    var firebaseEvent: FirebaseEvent {
        FirebaseEvent(
            id: id,
            name: name,
            descriptionString: descriptionString,
            locationDescription: locationDescription,
            startTimestamp: .init(date: startDate),
            endTimestamp: .init(date: endDate),
            lastModified: .init(date: lastModified)
        )
    }
}

struct FirebaseEvent: Codable {
    var id: String = UUID().uuidString
    var name: String
    var descriptionString: String
    var locationDescription: String
    var startTimestamp: Timestamp
    var endTimestamp: Timestamp
    var lastModified: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case name
        case descriptionString = "description"
        case locationDescription
        case startTimestamp
        case endTimestamp
        case lastModified
    }
}

extension FirebaseEvent {
    var event: Event {
        Event(
            id: id,
            name: name,
            description: descriptionString,
            locationDescription: locationDescription,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            lastModified: lastModified
        )
    }
}
