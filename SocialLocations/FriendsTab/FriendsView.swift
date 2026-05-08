//
//  FriendsView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/9/26.
//

import SwiftUI

struct FriendsView: View {
    
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var friendToDelete: AppUser? = nil
    @State private var showDeleteAlert = false
    @AppStorage("hasSeenFriendsTutorial") private var hasSeenFriendsTutorial = false
    @State private var showFriendsTutorial = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                List {
                    // Search Results
                    if !searchText.isEmpty {
                        Section("Search Results") {
                            if viewModel.isLoading {
                                ProgressView()
                            } else if viewModel.searchResults.isEmpty {
                                Text("No users found")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(viewModel.searchResults) { user in
                                    userRow(user)
                                }
                            }
                        }
                    }
                    
                    // Friend Requests
                    if searchText.isEmpty && !viewModel.incomingRequests.isEmpty {
                        Section("Friend Requests") {
                            ForEach(viewModel.incomingRequests) { request in
                                requestRow(request, viewModel: viewModel)
                            }
                        }
                    }
                    
                    // FriendsList
                    if searchText.isEmpty {
                        Section("Friends") {
                            if viewModel.friends.isEmpty {
                                Text("No friends yet")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(viewModel.friends) { friend in
                                    friendRow(friend)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                if showFriendsTutorial {
                    TutorialOverlay(
                        message: "Search for friends by username or phone number. Accept or decline incoming requests here.",
                        onDismiss: {
                            withAnimation { showFriendsTutorial = false }
                        }
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search by username")
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await viewModel.searchUsers(by: newValue)
                }
            }
            .navigationTitle("Friends")
            .task { 
                guard !hasSeenFriendsTutorial else { return }
                try? await Task.sleep(nanoseconds: 800_000_000)
                hasSeenFriendsTutorial = true
                withAnimation { showFriendsTutorial = true }
            }
            .alert("Remove Friend", isPresented: $showDeleteAlert, presenting: friendToDelete) { friend in
                Button("Remove", role: .destructive) {
                    Task { viewModel.deleteFriends(friendId: friend.id ?? "") }
                }
                Button("Cancel", role: .cancel) { }
            } message: { friend in
                Text("Are you sure you want to remove \(friend.username) from your friends?")
            }
        }
    }
    
    @ViewBuilder
    private func friendRow(_ user: AppUser) -> some View {
        HStack {
            UserAvatarView(profileImageURL: user.profileImageURL)
            
            Text(user.username)
            
            Spacer()
            
            Button {
                friendToDelete = user
                showDeleteAlert = true
            } label : {
                Label ("Delete Friend", systemImage: "person.slash")
            }
            .buttonStyle(DeleteFriendOptionButtonStyle())
        }
    }
    
    
    @ViewBuilder
    private func requestRow(_ request: FriendRequest, viewModel: FriendsViewModel) -> some View {
        HStack (spacing: 3){
            UserAvatarView(profileImageURL: viewModel.requestUsers[request.fromUserId]?.profileImageURL)
            Text(viewModel.requestUsers[request.fromUserId]?.username ?? "Loading...")
            
            Spacer()
            
            Button {
                Task { await viewModel.acceptRequest(request) }
            } label: {
                Image (systemName: "checkmark")
            }
            .buttonStyle(FriendAcceptButtonStyle())
            
            Button {
                Task { await viewModel.rejectRequest(request) }
            } label : {
                Image (systemName: "xmark")
            }
            .buttonStyle(FriendDestructiveButtonStyle())
        }
    }
    
    @ViewBuilder
    private func userRow(_ user: AppUser) -> some View {
        HStack {
            UserAvatarView(profileImageURL: user.profileImageURL)
            
            VStack(alignment: .leading) {
                Text(user.username)
                Text(user.email).font(.caption)
            }
            
            Spacer()
            
            if viewModel.friends.contains(where: { $0.id == user.id }) {
                // Already friends (arrived via a direct search result before the list refreshed)
                Text("Already Friends")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appDarkGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appDarkGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
 
            } else if viewModel.sentRequestUserIds.contains(user.id!) {
                // A pending request has been sent but not yet accepted
                Text("Request Sent")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSub)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.textSub.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
 
            } else {
                Button {
                    Task { await viewModel.sendFriendRequest(to: user) }
                } label: {
                    Label("Add Friend", systemImage: "plus")
                }
                .buttonStyle(FriendOptionButtonStyle())
            }
        }
    }
}

private struct UserAvatarView: View {
    let profileImageURL: String?
    
    var body: some View {
        Group {
            if let urlString = profileImageURL,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
        }
    }
}






