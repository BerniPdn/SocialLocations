//
//  PinModel.swift
//  SocialLocations
//
//  Created by Irene Gallini on 3/22/26.
//

import Foundation
import MapKit
import FirebaseFirestore

class PinsModel: ObservableObject {

    @Published var pins: [Pin] = []

    init() {
        listenToPins()
    }

    // SAVE PIN
    func savePin(coordinate: CLLocationCoordinate2D, name: String, comment: String, rating: Int) async {

        FirestoreManager.shared.addPin(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            title: name
        )
    }

    // LISTEN TO PINS (REALTIME)
    func listenToPins() {

        FirestoreManager.shared.listenToPins { documents in

            DispatchQueue.main.async {
                self.pins = documents.map { doc in

                    let lat = doc["latitude"] as? Double ?? 0
                    let lon = doc["longitude"] as? Double ?? 0
                    let title = doc["title"] as? String ?? ""

                    return Pin(
                        id: doc.documentID,
                        name: title,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        address: nil
                    )
                }
            }
        }
    }
}
