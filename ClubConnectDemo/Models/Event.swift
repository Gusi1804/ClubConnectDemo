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
        self.descriptionString = description
        self.locationDescription = locationDescription
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        if let lastModified {
            self.lastModified = lastModified
        } else {
            self.lastModified = .init(date: Date())
        }
    }
    
    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.descriptionString = try values.decodeIfPresent(String.self, forKey: .descriptionString) ?? ""
        self.locationDescription = try values.decodeIfPresent(String.self, forKey: .locationDescription) ?? ""
        self.startTimestamp = try values.decodeIfPresent(Timestamp.self, forKey: .startTimestamp) ?? .init(date: Date())
        self.endTimestamp = try values.decodeIfPresent(Timestamp.self, forKey: .endTimestamp) ?? .init(date: Date())
        if let lastModified = try? values.decode(Timestamp.self, forKey: .lastModified) {
            self.lastModified = lastModified
        } else {
            self.lastModified = .init(date: Date())
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(descriptionString, forKey: .descriptionString)
        try container.encode(locationDescription, forKey: .locationDescription)
        try container.encode(startTimestamp, forKey: .startTimestamp)
        try container.encode(endTimestamp, forKey: .endTimestamp)
        try container.encode(lastModified, forKey: .lastModified)
    }
}
