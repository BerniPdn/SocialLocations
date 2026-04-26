//
//  SignUpView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import SwiftUI
import FirebaseAuth

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
                AppBackground ()
                
                VStack(spacing: 10) {
                    Spacer()
                    (
                        Text("Create ")
                            .foregroundStyle(Color.appGreen)
                        
                        + Text("Account")
                            .foregroundStyle(Color.appRed)
                    )
                    .font(.system(size: 35, weight: .black))
                    
                    VStack(spacing: 14) {
                        Group {
                            HStack(spacing:10){
                                Image(systemName: "person")
                                    .foregroundStyle(Color.appBlue)
                                    .frame(width: 10)
                                TextField("", text: $username, prompt: Text("Username")
                                    .foregroundStyle(Color.textSub.opacity(0.6))
                                )
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color.textMain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appGreen.opacity(0.3), lineWidth: 1.5)
                            )
                            
                            HStack(spacing:10) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(Color.appBlue)
                                    .frame(width: 10)
                                TextField("", text: $email, prompt: Text("Email address")
                                    .foregroundStyle(Color.textSub.opacity(0.6))
                                )
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color.textMain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appGreen.opacity(0.3), lineWidth: 1.5)
                            )
                            
                            HStack(spacing:10){
                                Image(systemName: "lock")
                                    .foregroundStyle(Color.appBlue)
                                    .frame(width: 10)
                                SecureField("", text: $password, prompt: Text("Password")
                                    .foregroundStyle(Color.textSub.opacity(0.6))
                                )
                                .foregroundStyle(Color.textMain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appGreen.opacity(0.3), lineWidth: 1.5)
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
                            .background(Color.appGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.appGreen.opacity(0.35), radius: 10, y: 5)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBlue.opacity(0.3), lineWidth: 1.5)
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
                            .foregroundStyle(Color.appRed)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                        }
                    }
                    .padding(22)
                    .background(Color.white.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.appGreen.opacity(0.15), lineWidth: 1.5)
                    )
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 26)
            }
            .onChange(of: authViewModel.user?.uid) { _, newValue in
                if newValue != nil {
                    dismiss()
                }
            }
        }
    }
}


    

