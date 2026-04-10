//
//  AuthManager.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager {
    static let shared = AuthManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Sign Up
    func signUp(
        email: String,
        password: String,
        username: String,
        phoneNumber: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else { return }
            
            let appUser = AppUser(
                id: user.uid,
                username: username,
                usernameLower: username.lowercased(),
                phoneNumber: phoneNumber,
                profileImageURL: "",
                email: email,
                friendIDs: []
            )
            
            do {
                try self.db.collection("users").document(user.uid).setData(from: appUser) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(user))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Fetch Firestore User
    func fetchCurrentAppUser(completion: @escaping (Result<AppUser, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            do {
                let user = try snapshot.data(as: AppUser.self)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
