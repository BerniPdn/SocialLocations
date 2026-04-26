//
//  LogInView.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                AppBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    (
                        Text("Pin")
                            .foregroundStyle(Color.appGreen)
                        + Text("Pals")
                            .foregroundStyle(Color.appRed)
                    )
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    
                    Text("Drop a pin, share a moment.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSub)
                        .tracking(0.8)
                        .padding(.top, 6)
                        .padding(.bottom, 44)
                    
                    VStack(spacing: 14) {
                        Group {
                            HStack(spacing:10){
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
                            .background(Color.appGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.appGreen.opacity(0.35), radius: 10, y: 5)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBlue.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                        
                        Button() {
                            showSignUp = true
                        } label : {
                            Text("Create Account")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.appBlue.opacity(0.07))
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
