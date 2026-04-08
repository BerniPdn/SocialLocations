//
//  PinModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import Combine

class PinsViewModel: ObservableObject {
    
    @Published var pins: [Pin] = []
    
    init() {
        listenToPins()
    }
    
    // SAVE PIN → Firestore
    func savePin(coordinate: CLLocationCoordinate2D,
                 name: String,
                 comment: String,
                 rating: Int,
                 category: PinCategory,
                 id: String) {
        
        FirestoreManager.shared.addPin(
            id: id,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            title: name,
            comment: comment,
            rating: rating,
            category: category.rawValue
        )
    }
    
    // REALTIME LISTENER
    func listenToPins() {
        FirestoreManager.shared.listenToPins { documents in
            DispatchQueue.main.async {
                self.pins = documents.compactMap { doc in
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
                        rating: doc["rating"] as? Int ?? 0
                    )
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
            category: .other
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
}




