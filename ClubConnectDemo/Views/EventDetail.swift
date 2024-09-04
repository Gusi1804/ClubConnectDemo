//
//  EventDetail.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct EventDetail: View {
    private var event: Event
    
    init(_ event: Event) {
        self.event = event
    }

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: "https://d112y698adiu2z.cloudfront.net/photos/production/challenge_photos/002/458/039/datas/full_width.png")) { image in
                image
                    .resizable()            // Make the image resizable
                    .aspectRatio(contentMode: .fit) // Keep the aspect ratio
            } placeholder: {
                ProgressView() // Show a loading indicator while the image is loading
            }
                .padding()
            
            Text(event.name)
                .font(.largeTitle).bold()
                
            Text(formattedTimeString)
                .font(.headline)
            
            Text("\(Image(systemName: "location")) \(event.locationDescription)")
                .padding(.bottom, 5)
            
            Text(event.description)
            
            Spacer()
        }
        .padding()
        .navigationTitle(event.name)
    }
    
    private var formattedDurationString: String {
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.maximumUnitCount = 2
            formatter.unitsStyle = .short
            return formatter
        }()
        return formatter.string(from: duration) ?? "Unknown"
    }
    
    private var formattedTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return "\(dateFormatter.string(from: event.startDate)), \(timeFormatter.string(from: event.startDate)) – \(timeFormatter.string(from: event.endDate))"
    }
}

#Preview {
    EventDetail(Event(
        name: "Hello",
        description: "This is a sample event for previews.",
        locationDescription: "CCB 102",
        startTimestamp: Timestamp(date: Date()),
        endTimestamp: Timestamp(date: Date().addingTimeInterval(3600)))
    )
}
