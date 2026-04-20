//
//  ContentView.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import MapKit

struct MainView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            FriendsView() // Replaces Text("Here you can see your friends")
                            .tabItem {
                                Label("Friends", systemImage: "globe")
                            }
            
            ProfileView() // Replaces Text("Here you can see your profile")
                            .tabItem {
                                Label("Your Profile", systemImage: "person")
                            }
        }
    }
}

#Preview {
    Text("Preview not supported")
}

