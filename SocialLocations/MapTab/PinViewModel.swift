//
//  PinModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth
import Combine


class PinsViewModel: ObservableObject {
    
    @Published var pins: [Pin] = []
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    @Published var friendIds: [String] = []
    @Published var selectedUserIds: Set<String> = [] // This will show all friends initially
    
    init() {
        //listenToPins()
    }
    
    // SAVE PIN → Firestore
    func savePin(coordinate: CLLocationCoordinate2D,
                 name: String,
                 comment: String,
                 rating: Int,
                 category: PinCategory,
                 id: String) {
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }

        FirestoreManager.shared.addPin(
            id: id,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            title: name,
            comment: comment,
            rating: rating,
            category: category.rawValue,
            userId: uid  // Connects to authenticated user
        )
    }
    
    // REALTIME LISTENER
//    func listenToPins() {
//        FirestoreManager.shared.listenToPins { documents in
//            DispatchQueue.main.async {
//                self.pins = documents.compactMap { doc in
//                    guard let lat = doc["latitude"] as? Double,
//                          let lon = doc["longitude"] as? Double,
//                          let title = doc["title"] as? String
//                    else { return nil }
//                    let existingAddress = self.pins.first(where: { $0.id == doc.documentID })?.address
//                    
//                    return Pin(
//                        id: doc.documentID,
//                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
//                        name: title,
//                        address: existingAddress,
//                        comment: doc["comment"] as? String ?? "",
//                        rating: doc["rating"] as? Int ?? 0,
//                        userId: doc["userId"] as? String ?? ""
//                    )
//                }
//            }
//        }
//    }
    func listenToPins(friendIDs: [String]) {
        let allowedIDs = Array(Set(friendIDs + [currentUserId])).filter { !$0.isEmpty }
        guard !allowedIDs.isEmpty else { return }

        // Firestore 'in' queries allow max 30 items
        let chunks = stride(from: 0, to: allowedIDs.count, by: 30).map {
            Array(allowedIDs[$0..<min($0 + 30, allowedIDs.count)])
        }

        for chunk in chunks {
            Firestore.firestore()
                .collection("pins")
                .whereField("userId", in: chunk)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    DispatchQueue.main.async {
                        let newPins: [Pin] = documents.compactMap { doc in
                            guard let lat = doc["latitude"] as? Double,
                                  let lon = doc["longitude"] as? Double,
                                  let title = doc["title"] as? String
                            else { return nil }
                            let existingAddress = self.pins.first(where: { $0.id == doc.documentID })?.address
                            return Pin(
                                id: doc.documentID,
                                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                name: title,
                                address: existingAddress,
                                comment: doc["comment"] as? String ?? "",
                                rating: doc["rating"] as? Int ?? 0,
                                category: PinCategory(rawValue: doc["category"] as? String ?? "") ?? .other,
                                userId: doc["userId"] as? String ?? "",
                                username: nil
                            )
                        }
                        // Getting username for each pin
                        var pinsWithUsernames = newPins
                        for i in pinsWithUsernames.indices {
                            let userId = pinsWithUsernames[i].userId
                            FirestoreManager.shared.fetchUsername(for: userId) { result in
                                DispatchQueue.main.async {
                                    if let index = self.pins.firstIndex(where: { $0.id == pinsWithUsernames[i].id }) {
                                        if case .success(let username) = result {
                                            self.pins[index].username = username
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Merge, replacing any pins from this chunk
                        let chunkUserIDs = Set(chunk)
                        self.pins = self.pins.filter { !chunkUserIDs.contains($0.userId) || $0.userId.isEmpty }
                        self.pins += newPins
                    }
                }
        }
    }
    
    
    // LOOK UP ADDRESS
    func lookupAddress(for id: String) async {
        guard let index = pins.firstIndex(where: { $0.id == id }) else { return }
        
        let coordinate = pins[index].coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        guard let request = MKReverseGeocodingRequest(location: location) else {
            print("Failed to create reverse geocoding request")
            return
        }
        
        do {
            let mapItems = try await request.mapItems
            
            if let first = mapItems.first, let mkAddress = first.address {
                pins[index].address = mkAddress.shortAddress
            }
        } catch {
            print("Reverse geocoding failed:", error)
        }
    }
    
    func addLocalPin(coordinate: CLLocationCoordinate2D, id: String) {
        pins.append(Pin(
            id: id,
            coordinate: coordinate,
            name: "",
            address: nil,
            comment: "",
            rating: 0,
            category: .other,
            userId: "",
        ))
    }
    
    func removeLocalPin(id: String) {
        pins.removeAll { $0.id == id }
    }
    
    func deletePin(pinID: String) {
        pins.removeAll { $0.id == pinID }
        
        Firestore.firestore()
            .collection("pins")
            .document(pinID)
            .delete { error in
                if let error = error {
                    print("Error deleting pin: \(error)")
                }
            }
    }
    
    func updatePin(pin: Pin) {
        Firestore.firestore()
            .collection("pins")
            .document(pin.id)
            .setData([
                "title": pin.name,
                "comment": pin.comment,
                "rating": pin.rating,
                "category": pin.category.rawValue
            ], merge: true) { error in
                if let error = error {
                    print("Error updating pin: \(error)")
                } else {
                    print("Pin updated successfully")
                }
            }
    }
    
    // FUNCTIONS TO FILTER PINS
//    func listenToFriends() {
//        FirestoreManager.shared.listenToFriends { friendIds in
//            DispatchQueue.main.async {
//                self.friendIds = friendIds
//            }
//        }
//    }
    
    var filteredPins: [Pin] {
        if selectedUserIds.isEmpty {
            return pins
        }
        return pins.filter { selectedUserIds.contains($0.userId) }
    }
}



