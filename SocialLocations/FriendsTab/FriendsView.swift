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

    var body: some View {
        NavigationStack {
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
            .searchable(text: $searchText, prompt: "Search by username or phone number")
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()

                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        await viewModel.searchUsers(by: newValue)
//                Task{
//                await viewModel.searchUsers(by: newValue)
                    }
            }
            .navigationTitle("Friends")
        }
    }
    
    @ViewBuilder
    private func friendRow(_ user: AppUser) -> some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)

            Text(user.username)

            Spacer()

            Button("View") {
                // show their pins
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }


    @ViewBuilder
    private func requestRow(_ request: FriendRequest, viewModel: FriendsViewModel) -> some View {
        HStack {
            Text(viewModel.requestUsers[request.fromUserId]?.username ?? "Loading...")
            
            Spacer()

            Button("Accept") {
                Task { await viewModel.acceptRequest(request) }
            }
            .buttonStyle(.borderedProminent)

            Button("Reject") {
                Task { await viewModel.rejectRequest(request) }
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func userRow(_ user: AppUser) -> some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(user.username)
                Text(user.email).font(.caption)
            }

            Spacer()

            Button("Add") {
                Task {
                    await viewModel.sendFriendRequest(to: user)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
}






