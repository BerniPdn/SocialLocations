//
//  FriendsView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/9/26.
//

import SwiftUI

struct FriendsView: View {
    // Placeholder data
    let friends = ["Alex", "Jordan", "Taylor", "Sam"]

    var body: some View {
        NavigationStack {
            List(friends, id: \.self) { friend in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                    
                    Text(friend)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("View") {
                        // Action to see friend on map
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Friends")
            .toolbar {
                Button(action: { /* Add friend action */ }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
    }
}

