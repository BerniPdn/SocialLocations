//
//  AuthViewModel.swift
//  SocialLocations
//  //  Created by Irene Gallini on 4/3/26.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var appUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.user = Auth.auth().currentUser
        
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                
                if user != nil {
                    self?.loadCurrentUser()
                } else {
                    self?.appUser = nil
                }
            }
        }
    }

    func signUp(email: String, password: String, username: String, phoneNumber: String) {
        isLoading = true
        errorMessage = ""

        AuthManager.shared.signUp(
            email: email,
            password: password,
            username: username,
            phoneNumber: phoneNumber
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loadCurrentUser()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""

        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loadCurrentUser()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loadCurrentUser() {
        AuthManager.shared.fetchCurrentAppUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appUser):
                    self?.appUser = appUser
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        do {
            try AuthManager.shared.signOut()
            self.user = nil
            self.appUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
