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
    @State private var showProfileTutorial = false
    @AppStorage("hasSeenProfileTutorial") private var hasSeenProfileTutorial = false 
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 20) {
                    // Profile Picture
                    Group {
                        if let urlString = authViewModel.appUser?.profileImageURL,
                           !urlString.isEmpty,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                    }
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
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button(role: .destructive, action: {
                            authViewModel.signOut()
                        }) {
                            Label("Log Out", systemImage: "arrow.right.square")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Your Profile")
                if showProfileTutorial { 
                    TutorialOverlay(
                        message: "Edit your profile or log out here.",
                        onDismiss: {
                            withAnimation { showProfileTutorial = false }
                        }
                    )
                }
            }
        }
        .task {
            guard !hasSeenProfileTutorial else { return }
            try? await Task.sleep(nanoseconds: 800_000_000)
            hasSeenProfileTutorial = true
            withAnimation { showProfileTutorial = true }
        }
        .sheet(isPresented: $isEditShowing) {
            ProfileEditView()
                .environmentObject(authViewModel)
    }
        }
}
