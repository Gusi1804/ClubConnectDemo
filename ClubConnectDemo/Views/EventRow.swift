//
//  EventRow.swift
//  ClubConnectDemo
//
//  Created by Gustavo Garfias on 04/09/2024.
//

import SwiftUI

struct EventRow: View {
    let event: Event
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(event.formattedStartTimeString)
                    .font(.callout).bold()
                Text(event.formattedDurationString)
                    .font(.caption)
            }
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.callout).bold()
                Text("\(Image(systemName: "location")) \(event.locationDescription)")
                    .font(.caption).bold()
                Text(event.description)
                    .lineLimit(3)
                    .font(.caption)
                
            }
            Spacer()
        }
    }
}

#Preview {
    EventRow(event: Event.example1)
        .padding()
}
