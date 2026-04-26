//
//  SignUpView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import SwiftUI
import FirebaseAuth

private extension Color {
    static let backgroundMain = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let backgroundSecondary = Color(red: 0.91, green: 0.88, blue: 0.80)
    static let Green = Color(red: 0.18, green: 0.44, blue: 0.26)
    static let Blue = Color(red: 0.18, green: 0.38, blue: 0.62)
    static let Red = Color(red: 0.86, green: 0.18, blue: 0.18)
    static let TextMain = Color(red: 0.13, green: 0.14, blue: 0.16)
    static let TextSub = Color(red: 0.40, green: 0.42, blue: 0.46)
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    
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
                
                VStack(spacing: 10) {
                    Spacer()
                    (
                        Text("Create ")
                            .foregroundStyle(Color.Green)
                        
                        + Text("Account")
                            .foregroundStyle(Color.Red)
                    )
                    .font(.system(size: 35, weight: .black))
                    
                    VStack(spacing: 14) {
                        Group {
                            HStack(spacing:10){
                                Image(systemName: "person")
                                    .foregroundStyle(Color.Blue)
                                    .frame(width: 10)
                                TextField("", text: $username, prompt: Text("Username")
                                    .foregroundStyle(Color.TextSub.opacity(0.6))
                                )
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
                            
                            HStack(spacing:10) {
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
                            authViewModel.signUp(email: email, password: password, username: username,
                                                 phoneNumber: phoneNumber)
                            
                            let cleanUsername = username
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                            let cleanPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                        } label: {
                            Group {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("Sign Up")
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
                .padding()
                .onChange(of: authViewModel.user?.uid) { _, newValue in
                    if newValue != nil {
                        dismiss()
                    }
                }
            }
        }
    }
}
