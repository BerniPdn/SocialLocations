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

@ObservableObject
class PinsViewModel {

    @Published var pins: [Pin] = []

    init() {
        listenToPins()
    }

    // SAVE PIN → Firestore
    func savePin(coordinate: CLLocationCoordinate2D,
                 name: String,
                 comment: String,
                 rating: Int) async {

        FirestoreManager.shared.addPin(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            title: name
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
