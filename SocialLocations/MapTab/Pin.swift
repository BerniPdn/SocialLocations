//
//  Pins.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/8/26.
//

import SwiftUI
import MapKit
internal import Combine

struct Pin: Identifiable{
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var name: String
    var address: String?
    var comment: String
    var rating: Int
}

@MainActor
class PinsModel: ObservableObject {
    @Published var pins: [Pin] = []
    
    func savePin(coordinate: CLLocationCoordinate2D, name: String, comment: String, rating: Int) async{
        let newPin = Pin(coordinate: coordinate, name: name, comment: comment, rating: rating)
        pins.append(newPin)
        await MainActor.run{
            pins.append(newPin)
        }
        await lookupAddress(for: newPin.id)
    }
    
    func lookupAddress(for id: UUID) async {
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
                print("Address saved:", mkAddress.shortAddress)
            }
        } catch {
            print("Reverse geocoding failed:", error)
        }
    }
    
    func removePin(_ pin: Pin){
        pins.removeAll { $0.id == pin.id } //This is the same as writting eachPin in eachPin.id == pin.id - very useful shorthand in Swift!! - the $0 means: the first argument
    }
}

