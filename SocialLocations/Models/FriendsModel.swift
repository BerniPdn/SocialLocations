//
//  FriendsModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

//import Foundation
import SwiftUI
import Combine

class FriendsViewModel: ObservableObject {

    @Published var friendIDs: [String] = []

    init() {
        listenToFriends()
    }

    func listenToFriends() {
        FirestoreManager.shared.listenToFriends { ids in
            DispatchQueue.main.async {
                self.friendIDs = ids
            }
        }
    }
}
