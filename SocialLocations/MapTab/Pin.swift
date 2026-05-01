//
//  Pins.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/8/26.
//

import SwiftUI
import MapKit
//internal import Combine

enum PinCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case nightlife = "Nightlife"
    case nature = "Nature"
    case shopping = "Shopping"
    case culture = "Culture"
    case education = "Education"
    case other = "Other"
    
    var id: String { rawValue }
}

struct Pin: Identifiable{
    let id: String
    let coordinate: CLLocationCoordinate2D
    var name: String
    var address: String?
    var comment: String
    var rating: Int
    var category: PinCategory = .other
    var userId: String
    var username: String?
}
