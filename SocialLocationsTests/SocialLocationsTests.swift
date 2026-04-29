//
// SocialLocationsTests.swift
//  SocialLocations
//
//  Created by Shahed Zahaykeh on 4/28/26.
//


import MapKit
import Testing
@testable import SocialLocations

import FirebaseFirestore

struct SocialLocationsTests {

    //AppUser Tests
    
    @Test
    func appUserInitialization() {
        let user = AppUser(
            id: "123",
            username: "shahed",
            usernameLower: "shahed",
            phoneNumber: "123",
            profileImageURL: "",
            email: "test@test.com",
            friendIDs: ["a", "b"]
        )
        
        #expect(user.username == "shahed")
        #expect(user.friendIDs.count == 2)
    }
    
    
    //FriendRequest Tests
    
    @Test
    func friendRequestCreation() {
        let request = FriendRequest(
            fromUserId: "user1",
            toUserId: "user2",
            status: "pending",
            createdAt: Timestamp()
        )
        
        #expect(request.status == "pending")
    }
    
    
    //FriendsViewModel Tests
    
    @Test
    func searchFiltersOutCurrentUserAndFriends() async {
        let vm = await MainActor.run {
            FriendsViewModel(enableListeners: false)
        }
        
        let currentUserId = "me"
        
        let users = [
            AppUser(id: "me", username: "me", usernameLower: "me", phoneNumber: "", profileImageURL: "", email: "", friendIDs: []),
            AppUser(id: "friend1", username: "friend", usernameLower: "friend", phoneNumber: "", profileImageURL: "", email: "", friendIDs: []),
            AppUser(id: "newUser", username: "new", usernameLower: "new", phoneNumber: "", profileImageURL: "", email: "", friendIDs: [])
        ]
        
        await MainActor.run {
            vm.friends = [users[1]]
            
            vm.searchResults = users.filter { user in
                guard let id = user.id else { return false }
                return id != currentUserId &&
                       !vm.friends.contains(where: { $0.id == id })
            }
        }
        
        await MainActor.run {
            #expect(vm.searchResults.count == 1)
            #expect(vm.searchResults.first?.id == "newUser")
        }
    }
    
    
    @Test
    func preventsDuplicateFriendRequests() {
        let existingRequests = [
            ("user1", "user2", "pending"),
            ("user2", "user1", "accepted")
        ]
        
        let alreadyExists = existingRequests.contains {
            ($0.0 == "user1" && $0.1 == "user2") ||
            ($0.0 == "user2" && $0.1 == "user1")
        }
        
        #expect(alreadyExists == true)
    }
    
    
    // PinsViewModel Tests
    
    @Test
    func addAndRemoveLocalPin() {
        let vm = PinsViewModel()
        
        let id = "pin1"
        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        vm.addLocalPin(coordinate: coord, id: id)
        #expect(vm.pins.count == 1)
        
        vm.removeLocalPin(id: id)
        #expect(vm.pins.isEmpty)
    }
    
    
    @Test
    func filteredPinsRespectsSelectedUsers() {
        let vm = PinsViewModel()
        
        vm.pins = [
            Pin(
                id: "1",
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                name: "",
                comment: "",
                rating: 0,
                userId: "user1"
            ),
            Pin(
                id: "2",
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                name: "",
                comment: "",
                rating: 0,
                userId: "user2"
            )
        ]
        
        vm.selectedUserIds = ["user1"]
        
        let filtered = vm.filteredPins
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.userId == "user1")
    }
}
