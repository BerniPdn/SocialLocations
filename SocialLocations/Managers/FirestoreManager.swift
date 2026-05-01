//
//  FirestoreManager.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {

    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // PINS

    func addPin(id: String, latitude: Double, longitude: Double, title: String, comment: String, rating: Int, category: String, userId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        db.collection("pins").document(id).setData([
            "userId": userId,
            "latitude": latitude,
            "longitude": longitude,
            "title": title,
            "comment": comment,
            "rating": rating,
            "category": category,
            "timestamp": Timestamp(),
        ])
        {error in
            if let error = error {
                print("Firestore error: \(error)")
            } else {
                print("Pin saved to Firestore with id: \(id)")
            }
        }
    }

    func listenToPins(completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection("pins")
            .addSnapshotListener { snapshot, _ in
                completion(snapshot?.documents ?? [])
            }
    }

    // USERS

    func createUserProfile(user: User, username: String) {
        db.collection("users").document(user.uid).setData([
            "username": username,
            "email": user.email ?? "",
            "profileImageURL": ""
        ])
    }

    func searchUsers(username: String,
                     completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, _ in
                completion(snapshot?.documents ?? [])
            }
    }
    
    func updateUserProfile(appUser: AppUser, completion: @escaping (Result<AppUser, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        
        do {
            try self.db.collection("users").document(currentUserId).setData(from: appUser) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(appUser))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUsername(for userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let username = document?.data()?["username"] as? String else {
                completion(.failure(NSError(domain: "FirestoreManager", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
                return
            }
            
            completion(.success(username))
        }
    }

    // FRIENDS

    func sendFriendRequest(to userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        db.collection("friend_requests").addDocument(data: [
            "fromUserId": currentUserId,
            "toUserId": userId,
            "status": "pending"
        ])
    }

    func acceptFriendRequest(requestId: String) {
        db.collection("friend_requests")
            .document(requestId)
            .updateData(["status": "accepted"])
    }

    func listenToFriends(completion: @escaping ([String]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("friend_requests")
            .whereField("status", isEqualTo: "accepted")
            .addSnapshotListener { snapshot, _ in

                let friends = snapshot?.documents.compactMap { doc -> String? in
                    let from = doc["fromUserId"] as? String
                    let to = doc["toUserId"] as? String

                    if from == userId { return to }
                    if to == userId { return from }
                    return nil
                } ?? []

                completion(friends)
            }
    }
}
