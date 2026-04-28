//
//  AppButtonsStyle.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 4/26/26.
//

import SwiftUI
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appGreen.opacity(configuration.isPressed ? 0.4 : 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
    
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appBrown.opacity(configuration.isPressed ? 0.1 : 0.4))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
    
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appRed.opacity(configuration.isPressed ? 0.4 : 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

