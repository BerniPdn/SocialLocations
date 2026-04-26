//
//  AppBackground.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 4/26/26.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.backgroundMain, Color.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack {
                ForEach([0.6, 1.2, 1.8, 2.4], id: \.self) { scale in
                    Circle()
                        .stroke(Color.appGreen.opacity(0.045), lineWidth: 1.5)
                        .frame(width: 260, height: 260)
                        .scaleEffect(scale)
                        .offset(x: 110, y: -180)
                }
                ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { scale in
                    Circle()
                        .stroke(Color.appBlue.opacity(0.04), lineWidth: 1.5)
                        .frame(width: 220, height: 220)
                        .scaleEffect(scale)
                        .offset(x: -120, y: 260)
                }
            }
        }
    }
}
