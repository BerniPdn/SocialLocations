//
//  Pins.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/8/26.
//

import SwiftUI
import MapKit

// Categories a pin can be tagged with
enum PinCategory: String, CaseIterable, Identifiable {
    case culture = "Culture"
    case education = "Education"
    case food = "Food"
    case nature = "Nature"
    case nightlife = "Nightlife"
    case shopping = "Shopping"
    case other = "Other"
    
    var id: String { rawValue }
}

// Represents a saved location in the map
struct Pin: Identifiable{
    let id: String
    let coordinate: CLLocationCoordinate2D
    var name: String
    var address: String? // Optional in case address can't be found
    var comment: String
    var rating: Int
    var category: PinCategory = .other
    var userId: String // ID for the person who created the pin
    var username: String? // Cached for display without extra Firestore lookup
}
