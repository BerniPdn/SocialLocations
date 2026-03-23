//
//  ProfileView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/9/26.
//

import SwiftUI
import FirebaseAuth

var userEmail: String {
    Auth.auth().currentUser?.email ?? "No email"
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profile Picture
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                
                Text(userEmail)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sharing locations since 2026")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {}) {
                        Label("Edit Profile", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive, action: {}) {
                        Label("Log Out", systemImage: "arrow.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Your Profile")
        }
    }
}
