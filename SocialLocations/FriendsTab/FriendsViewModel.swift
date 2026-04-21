//
//  FriendsViewModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friendIDs: [String] = []
    @Published var friends: [AppUser] = []
    @Published var searchResults: [AppUser] = []
    @Published var incomingRequests: [FriendRequest] = []
    
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init() {
        Task {
            await fetchFriends()
            await fetchIncomingRequests()
        }
    }

    func fetchFriends() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()
            let currentUser = try userDoc.data(as: AppUser.self)
            let ids = currentUser.friendIDs
            self.friendIDs = ids

            if ids.isEmpty {
                self.friends = []
                return
            }

            let snapshots = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()

            self.friends = try snapshots.documents.compactMap {
                try $0.data(as: AppUser.self)
            }
        } catch {
            print("Error fetching friends: \(error)")
        }
    }

    func searchUsers(by username: String) async {
        guard !username.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        
        do {
            let snapshot = try await db.collection("users")
                .whereField("usernameLower", isGreaterThanOrEqualTo: username.lowercased())
                .whereField("usernameLower", isLessThanOrEqualTo: username.lowercased() + "\u{f8ff}")
                .getDocuments()

            let currentUID = Auth.auth().currentUser?.uid

            self.searchResults = try snapshot.documents.compactMap {
                let user = try $0.data(as: AppUser.self)
                return user.id == currentUID ? nil : user
            }
        } catch {
            print("Error searching users: \(error)")
        }
        
        isLoading = false
    }

    func sendFriendRequest(to user: AppUser) async {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let targetUID = user.id else { return }

        do {
            let existing = try await db.collection("friend_requests")
                .whereField("fromUserId", isEqualTo: currentUID)
                .whereField("toUserId", isEqualTo: targetUID)
                .whereField("status", isEqualTo: "pending")
                .getDocuments()

            if !existing.documents.isEmpty { return }

            let request = FriendRequest(
                fromUserId: currentUID,
                toUserId: targetUID,
                status: "pending",
                createdAt: Timestamp()
            )

            try db.collection("friend_requests").addDocument(from: request)
        } catch {
            print("Error sending friend request: \(error)")
        }
    }

    func fetchIncomingRequests() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("friend_requests")
                .whereField("toUserId", isEqualTo: uid)
                .whereField("status", isEqualTo: "pending")
                .getDocuments()

            self.incomingRequests = try snapshot.documents.compactMap {
                try $0.data(as: FriendRequest.self)
            }
        } catch {
            print("Error fetching requests: \(error)")
        }
    }

    func acceptRequest(_ request: FriendRequest) async {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        do {
            guard let requestId = request.id else { return }

            let fromUserRef = db.collection("users").document(request.fromUserId)
            let toUserRef = db.collection("users").document(currentUID)
            let requestRef = db.collection("friend_requests").document(requestId)

            let batch = db.batch()

            batch.updateData([
                "friendIDs": FieldValue.arrayUnion([currentUID])
            ], forDocument: fromUserRef)

            batch.updateData([
                "friendIDs": FieldValue.arrayUnion([request.fromUserId])
            ], forDocument: toUserRef)

            batch.updateData([
                "status": "accepted"
            ], forDocument: requestRef)

            try await batch.commit()

            await fetchFriends()
            await fetchIncomingRequests()
        } catch {
            print("Error accepting request: \(error)")
        }
    }

    func rejectRequest(_ request: FriendRequest) async {
        guard let requestId = request.id else { return }

        do {
            try await db.collection("friend_requests")
                .document(requestId)
                .updateData(["status": "rejected"])

            await fetchIncomingRequests()
        } catch {
            print("Error rejecting request: \(error)")
        }
    }
}
