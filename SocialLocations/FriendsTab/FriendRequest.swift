//
//  FriendRequest.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/6/26.
//

import Foundation
import FirebaseFirestore

// status flows: "pending" → "accepted" or "rejected"
struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let fromUserId: String
    let toUserId: String
    let status: String
    let createdAt: Timestamp
}
