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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("PinPals")
                    .font(.system(size: 70))
                    .fontWeight(.bold)
                
                
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
            .navigationTitle("Welcome")
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
