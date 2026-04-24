////
////  SearchFriendsView.swift
////  SocialLocations
////
////  Created by Irene Gallini on 4/6/26.
////
//
//import SwiftUI
//
//struct SearchFriendsView: View {
//    @ObservedObject var viewModel: FriendsViewModel
//    @State private var searchText = ""
//    @State private var showSearch = false
//
//    var body: some View
//        Group {
//            if searchText.isEmpty {
//                ContentUnavailableView(
//                    "Search for friends",
//                    systemImage: "person.2",
//                    description: Text("Type a username to find people")
//                )
//            } else if viewModel.isLoading {
//                ProgressView("Searching...")
//            } else if viewModel.searchResults.isEmpty {
//                ContentUnavailableView(
//                    "No results",
//                    systemImage: "magnifyingglass",
//                    description: Text("Try a different username")
//                )
//            } else {
//                List {
//                    ForEach(viewModel.searchResults) { user in
//                        userRow(user)
//                    }
//                }
//            }
//        }
//        .searchable(text: $searchText, prompt: "Search by username")
//        .onChange(of: searchText) { _, newValue in
//            Task {
//                await viewModel.searchUsers(by: newValue)
//            }
//        }
//        .navigationTitle("Find Friends")
//    }
//    
//    @ViewBuilder
//        private func userRow(_ user: AppUser) -> some View {
//            HStack {
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.blue)
//
//                VStack(alignment: .leading) {
//                    Text(user.username)
//                        .font(.headline)
//                    Text(user.email)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//
//                Spacer()
//
//                Button("Add") {
//                    Task {
//                        await viewModel.sendFriendRequest(to: user)
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.small)
//            }
//            .padding(.vertical, 4)
//        }
//}
