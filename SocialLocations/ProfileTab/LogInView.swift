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

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Log In") {
                        authViewModel.signIn(email: email, password: password)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    Button("Create Account") {
                        showSignUp = true
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    if authViewModel.isLoading {
                        ProgressView()
                    }
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showSignUp) {
                    SignUpView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
