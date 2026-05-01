//
//  AppUser.swift
//  SocialLocations
//
//  Created by Irene Gallini on 4/3/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    
    let username: String
    let usernameLower: String
    let phoneNumber: String
    let profileImageURL: String
    let email: String
    let friendIDs: [String]
}
