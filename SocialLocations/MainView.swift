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
            
            FriendsView() 
                            .tabItem {
                                Label("Friends", systemImage: "globe")
                            }
            
            ProfileView()
                            .tabItem {
                                Label("Your Profile", systemImage: "person")
                            }
        }
        .tint(.appDarkGreen)
        .preferredColorScheme(.light)
    }
}

#Preview {
    Text("Preview not supported")
}

