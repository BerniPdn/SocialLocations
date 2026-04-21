//
//  FriendsView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/9/26.
//

import SwiftUI

struct FriendsView: View {
    
    @StateObject private var viewModel = FriendsViewModel()
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            List(viewModel.friendIDs, id: \.self) { friendID in
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                    
                    Text(friendID)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("View") {
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Friends")
            .toolbar {
                            Button {
                                showSearch = true
                            } label: {
                                Image(systemName: "person.badge.plus")
                            }
                        }

            .navigationDestination(isPresented: $showSearch) {
                            SearchFriendsView(viewModel: viewModel)
                        }
        }
    }
}

