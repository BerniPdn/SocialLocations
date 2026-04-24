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
    @Published var requestUsers: [String: AppUser] = [:]

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

//            let snapshots = try await db.collection("users")
//                .whereField(FieldPath.documentID(), in: ids)
//                .getDocuments()
            var allUsers: [AppUser] = []

            let chunks = stride(from: 0, to: ids.count, by: 10).map {
                Array(ids[$0..<min($0 + 10, ids.count)])
            }

            for chunk in chunks {
                let snapshot = try await db.collection("users")
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments()

                let users = try snapshot.documents.compactMap {
                    try $0.data(as: AppUser.self)
                }

                allUsers.append(contentsOf: users)
            }

            self.friends = allUsers
            
        } catch {
            print("Error fetching friends: \(error)")
        }
    }

    func searchUsers(by text: String) async {
        guard !text.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let queryText = text.lowercased()
            
            let snapshot = try await db.collection("users")
                        .whereField("username", isGreaterThanOrEqualTo: queryText)
                        .whereField("username", isLessThanOrEqualTo: queryText + "\u{f8ff}")
                        .getDocuments()
            
            let currentUID = Auth.auth().currentUser?.uid

            let users = snapshot.documents.compactMap {
                try? $0.data(as: AppUser.self)
            }
            
            self.searchResults = users.filter { user in
                        guard let id = user.id else { return false }
                        return id != currentUID && !friendIDs.contains(id)
                    }
            
            
            // CAREFUL : Firebase mismatch
//            let usernameQuery = db.collection("users")
//                .whereField("username", isGreaterThanOrEqualTo: queryText)
//                .whereField("username", isLessThanOrEqualTo: queryText + "\u{f8ff}")
//
//            let phoneQuery = db.collection("users")
//                .whereField("phoneNumber", isGreaterThanOrEqualTo: text)
//                .whereField("phoneNumber", isLessThanOrEqualTo: text + "\u{f8ff}")

//            async let usernameSnapshot = usernameQuery.getDocuments()
//            async let phoneSnapshot = phoneQuery.getDocuments()
//
//            let (uSnap, pSnap) = try await (usernameSnapshot, phoneSnapshot)
//
//            let currentUID = Auth.auth().currentUser?.uid
//
//            let users = (uSnap.documents + pSnap.documents).compactMap {
//                try? $0.data(as: AppUser.self)
//            }
//
//            // remove duplicates + self
//            let unique = Dictionary(grouping: users, by: { $0.id })
//                .compactMap { $0.value.first }
//                .filter { user in
//                    guard let id = user.id else { return false }
//                    return id != currentUID && !friendIDs.contains(id)
//                }
//
//            self.searchResults = unique

        } catch {
            print("Search error:", error)
        }
        
        // DEBUGGING
//        print("QUERY:", text)
//
//        print("USERNAME SNAP:", uSnap.documents.map { $0.data() })
//        print("PHONE SNAP:", pSnap.documents.map { $0.data() })

//        isLoading = false

    }

    func sendFriendRequest(to user: AppUser) async {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let targetUID = user.id else { return }

        do {
            let existing = try await db.collection("friend_requests")
                .whereField("fromUserId", in: [currentUID, targetUID])
                .whereField("toUserId", in: [currentUID, targetUID])
                .getDocuments()

            if existing.documents.contains(where: {
                let data = $0.data()
                return data["status"] as? String == "pending" || data["status"] as? String == "accepted"
            }) {
                return
            }

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
        self.searchResults.removeAll { $0.id == targetUID }
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
        await loadRequestUsers()
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
    
    func loadRequestUsers() async {
        let ids = incomingRequests.map { $0.fromUserId }

        guard !ids.isEmpty else { return }

        do {
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()

            for doc in snapshot.documents {
                let user = try doc.data(as: AppUser.self)
                if let id = user.id {
                    requestUsers[id] = user
                }
            }
        } catch {
            print("Error loading request users")
        }
    }
}
