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

/// Data used by FriendsView.
///
@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [AppUser] = []
    @Published var searchResults: [AppUser] = []
    @Published var incomingRequests: [FriendRequest] = []
    @Published var isLoading = false
    @Published var requestUsers: [String: AppUser] = [:]
    

    private let db = Firestore.firestore()
    private var requestsListener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?

    init() {
        listenForIncomingRequests()
        listenForFriends()
    }
    
    nonisolated deinit {
        requestsListener?.remove()
        friendsListener?.remove()
    }

    // real time listeners
    func listenForIncomingRequests() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
     
            requestsListener = db.collection("friend_requests")
                .whereField("toUserId", isEqualTo: uid)
                .whereField("status", isEqualTo: "pending")
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self, let docs = snapshot?.documents else {
                        if let error { print("Requests listener error: \(error)") }
                        return
                    }
                    Task { @MainActor in
                        self.incomingRequests = (try? docs.compactMap {
                            try $0.data(as: FriendRequest.self)
                        }) ?? []
                        await self.loadRequestUsers()
                    }
                }
        }
    
    func listenForFriends() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
     
            friendsListener = db.collection("users").document(uid)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }
                    if let error { print("Friends listener error: \(error)"); return }
                    Task { @MainActor in
                        guard let user = try? snapshot?.data(as: AppUser.self) else { return }
                        await self.fetchFriendsByIDs(user.friendIDs)
                    }
                }
        }
    
    // Data fetching
    func fetchFriendsByIDs(_ ids: [String]) async {
            guard !ids.isEmpty else {
                self.friends = []
                return
            }
            do {
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
                print("Error fetching friends by IDs: \(error)")
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
                    .whereField("usernameLower", isGreaterThanOrEqualTo: queryText)
                    .whereField("usernameLower", isLessThanOrEqualTo: queryText + "\u{f8ff}")
                    .getDocuments()
     
                let currentUID = Auth.auth().currentUser?.uid
                let users = snapshot.documents.compactMap {
                    try? $0.data(as: AppUser.self)
                }
     
                self.searchResults = users.filter { user in
                    guard let id = user.id else { return false }
                    return id != currentUID && !friends.contains(where: { $0.id == id })
                }
            } catch {
                print("Search error: \(error)")
            }
        }
    
    func sendFriendRequest(to user: AppUser) async {
            guard let currentUID = Auth.auth().currentUser?.uid,
                  let targetUID = user.id else { return }
     
            do {
                // Check A→B direction
                let snap1 = try await db.collection("friend_requests")
                    .whereField("fromUserId", isEqualTo: currentUID)
                    .whereField("toUserId", isEqualTo: targetUID)
                    .getDocuments()
     
                // Check B→A direction
                let snap2 = try await db.collection("friend_requests")
                    .whereField("fromUserId", isEqualTo: targetUID)
                    .whereField("toUserId", isEqualTo: currentUID)
                    .getDocuments()
     
                let alreadyExists = (snap1.documents + snap2.documents).contains {
                    let status = $0.data()["status"] as? String
                    return status == "pending" || status == "accepted"
                }
     
                guard !alreadyExists else { return }
     
                let request = FriendRequest(
                    fromUserId: currentUID,
                    toUserId: targetUID,
                    status: "pending",
                    createdAt: Timestamp()
                )
                try db.collection("friend_requests").addDocument(from: request)
                self.searchResults.removeAll { $0.id == targetUID }
            } catch {
                print("Error sending friend request: \(error)")
            }
        }
     
    func acceptRequest(_ request: FriendRequest) async {
            guard let currentUID = Auth.auth().currentUser?.uid,
                  let requestId = request.id else { return }
     
            do {
                let fromUserRef = db.collection("users").document(request.fromUserId)
                let toUserRef = db.collection("users").document(currentUID)
                let requestRef = db.collection("friend_requests").document(requestId)
     
                let batch = db.batch()
                batch.updateData(["friendIDs": FieldValue.arrayUnion([currentUID])], forDocument: fromUserRef)
                batch.updateData(["friendIDs": FieldValue.arrayUnion([request.fromUserId])], forDocument: toUserRef)
                batch.updateData(["status": "accepted"], forDocument: requestRef)
                try await batch.commit()
                // Listeners automatically update friends and incomingRequests
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
                // Listener automatically removes it from incomingRequests
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
                if let user = try? doc.data(as: AppUser.self), let id = user.id {
                    requestUsers[id] = user
                }
            }
        } catch {
            print("Error loading request users: \(error)")
        }
    }
    
    
    }
    
    
