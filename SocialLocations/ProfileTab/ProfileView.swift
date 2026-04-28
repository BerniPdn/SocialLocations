//
//  ProfileView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/9/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditShowing = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profile Picture
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                
                Text(authViewModel.appUser?.username ?? "No Username")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(authViewModel.appUser?.email ?? "No email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Sharing locations since 2026")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    Button(action: {
                        isEditShowing = true
                        
                    }) {
                        Label("Edit Profile", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive, action: {
                        authViewModel.signOut()
                    }) {
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
        .sheet(isPresented: $isEditShowing) {
            ProfileEditView()
                .environmentObject(authViewModel)
    }
        }
}
