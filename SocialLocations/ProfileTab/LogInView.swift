//
//  LogInView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import SwiftUI

private extension Color {
    static let backgroundMain = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let backgroundSecondary = Color(red: 0.91, green: 0.88, blue: 0.80)
    static let Green = Color(red: 0.18, green: 0.44, blue: 0.26)
    static let Blue = Color(red: 0.18, green: 0.38, blue: 0.62)
    static let Red = Color(red: 0.86, green: 0.18, blue: 0.18)
    static let TextMain = Color(red: 0.13, green: 0.14, blue: 0.16)
    static let TextSub = Color(red: 0.40, green: 0.42, blue: 0.46)
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: [
                        Color(Color.backgroundMain),
                        Color(Color.backgroundSecondary)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    ForEach([0.6, 1.2, 1.8, 2.4], id: \.self) { scale in
                        Circle()
                            .stroke(Color.Green.opacity(0.045), lineWidth: 1.5)
                            .frame(width: 260, height: 260)
                            .scaleEffect(scale)
                            .offset(x: 110, y: -180)
                    }
                    ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { scale in
                        Circle()
                            .stroke(Color.Blue.opacity(0.04), lineWidth: 1.5)
                            .frame(width: 220, height: 220)
                            .scaleEffect(scale)
                            .offset(x: -120, y: 260)
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    (
                        Text("Pin")
                            .foregroundStyle(Color.Green)
                        + Text("Pals")
                            .foregroundStyle(Color.Red)
                    )
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    
                    Text("Drop a pin, share a moment.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.TextSub)
                        .tracking(0.8)
                        .padding(.top, 6)
                        .padding(.bottom, 44)
                    
                    VStack(spacing: 14) {
                        Group {
                            HStack(spacing:10){
                                Image(systemName: "envelope")
                                    .foregroundStyle(Color.Blue)
                                    .frame(width: 10)
                                TextField("", text: $email, prompt: Text("Email address")
                                    .foregroundStyle(Color.TextSub.opacity(0.6))
                                )
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color.TextMain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.Green.opacity(0.3), lineWidth: 1.5)
                            )
                            
                            HStack(spacing:10){
                                Image(systemName: "lock")
                                    .foregroundStyle(Color.Blue)
                                    .frame(width: 10)
                                SecureField("", text: $password, prompt: Text("Password")
                                    .foregroundStyle(Color.TextSub.opacity(0.6))
                                )
                                .foregroundStyle(Color.TextMain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.Green.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        
                        Button {
                            authViewModel.signIn(email: email, password: password)
                            
                        } label: {
                            Group {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("Log In")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.Green)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.Green.opacity(0.35), radius: 10, y: 5)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.Blue.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        
                        Button() {
                            showSignUp = true
                        } label : {
                            Text("Create Account")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.Blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.Blue.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        
                        if authViewModel.isLoading {
                            ProgressView()
                        }
                        
                        if !authViewModel.errorMessage.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(authViewModel.errorMessage)
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color.Red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                        }
                    }
                    .padding(22)
                    .background(Color.white.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.Green.opacity(0.15), lineWidth: 1.5)
                    )
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 26)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
