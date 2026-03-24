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
                self.pins = documents.map { doc in

                    let lat = doc["latitude"] as? Double ?? 0
                    let lon = doc["longitude"] as? Double ?? 0
                    let title = doc["title"] as? String ?? ""

                    return Pin(
                        id: doc.documentID,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        name: title,
                        address: nil,
                        comment: "",
                        rating: 0
                    )
                }
            }
        }
    }
}
