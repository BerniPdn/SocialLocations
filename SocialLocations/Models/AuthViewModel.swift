//
//  AuthViewModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/3/26.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var appUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    init() {
        self.user = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            if let user = user {
                Task {
                    await self?.fetchCurrentUser(uid: user.uid)
                }
            } else {
                self?.appUser = nil
            }
        }
    }

    func signUp(email: String, password: String, username: String, phoneNumber: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            let newUser = AppUser(
                id: uid,
                username: username,
                usernameLower: username.lowercased(),
                phoneNumber: phoneNumber,
                profileImageURL: "",
                email: email,
                friendIDs: []
            )

            try db.collection("users").document(uid).setData(from: newUser)
            self.appUser = newUser
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchCurrentUser(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchCurrentUser(uid: String) async {
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            self.appUser = try snapshot.data(as: AppUser.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.appUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
