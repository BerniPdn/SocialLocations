//
//  TutorialOverlay.swift
//  SocialLocations
//
//  Created by Irene Gallini on 5/5/26.
//

//  A simple first-visit tooltip overlay. Drop it into any ZStack and it
//  floats at the bottom of the screen with a tap-to-dismiss behaviour.
//  Persistence is handled by the caller via @AppStorage so each tab only
//  shows its tutorial once per device install.
//
 
import SwiftUI
 
struct TutorialOverlay: View {
    let message: String
    let onDismiss: () -> Void
 
    var body: some View {
        VStack {
            Spacer()
 
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "hand.tap.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appDarkGreen)
 
                    Text(message)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
 
                    Spacer()
                }
 
                Button(action: onDismiss) {
                    Text("Got it")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.appDarkGreen, in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 6)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        // Dim the background slightly so the card pops
        .background(Color.black.opacity(0.25).ignoresSafeArea())
        // Also allow tapping the dimmed area to dismiss
        .onTapGesture { onDismiss() }
        // But don't let the card tap propagate upward
        .gesture(TapGesture().onEnded { })
    }
}
 
