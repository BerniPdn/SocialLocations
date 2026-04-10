//
//  SearchFriendsView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import SwiftUI

struct SearchFriendsView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(viewModel.searchResults) { user in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $searchText, prompt: "Search by username")
        .onChange(of: searchText) { _, newValue in
            Task {
                await viewModel.searchUsers(by: newValue)
            }
        }
        .navigationTitle("Find Friends")
    }
}
