//
//  RootView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/3/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.user != nil {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}
