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
                 id: String = UUID().uuidString) async {
        
        await MainActor.run {
            pins.append(Pin(
                id: id,
                coordinate: coordinate,
                name: name,
                address: nil,
                comment: comment,
                rating: rating,
                category: category
            ))
        }
        
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
                //<<<<<<< HEAD
                self.pins = documents.compactMap { doc in
                    
                    guard let lat = doc["latitude"] as? Double,
                          let lon = doc["longitude"] as? Double,
                          let title = doc["title"] as? String
                    else {
                        return nil
                    }
                    
                    //=======
                    self.pins = documents.map { doc in
                        
                        let lat = doc["latitude"] as? Double ?? 0
                        let lon = doc["longitude"] as? Double ?? 0
                        let title = doc["title"] as? String ?? ""
                        let existingAddress = self.pins.first(where: { $0.id == doc.documentID })?.address
                        
                        
                        //>>>>>>> 60427f9f5506af2ff5bfe41576e8b00ecddad684
                        return Pin(
                            id: doc.documentID,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            name: title,
                            address: existingAddress,
                            comment: "",
                            rating: 0
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
    }
}


