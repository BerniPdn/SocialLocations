//
//  SetUpMap.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import MapKit

struct Location {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let imageName: String
    let width: CGFloat
    let height: CGFloat
}
    
struct FixedLocations {
    static let all: [Location] = [
        Location(name: "Macalester College", coordinate: CLLocationCoordinate2D(latitude: 44.93803318265245, longitude: -93.16845358110233), imageName: "Macalester",  width: 50, height: 30),
        Location(name: "St Paul State Capitol", coordinate: CLLocationCoordinate2D(latitude: 44.956020598408124, longitude: -93.1019029470677), imageName: "Capitol", width: 70, height: 70),
        Location(name: "Saint Paul Cathedral", coordinate: CLLocationCoordinate2D(latitude: 44.94723472487771, longitude: -93.10910008756574), imageName: "Cathedral", width: 70, height: 70),
        Location(name: "Como Zoo and Conservatory", coordinate: CLLocationCoordinate2D(latitude: 44.981352949299186, longitude: -93.15244850290573), imageName: "Zoo", width: 70, height: 70),
        Location(name: "Saint Paul/Minneapolis Airport", coordinate: CLLocationCoordinate2D(latitude: 44.88616711571032, longitude: -93.21482139766455), imageName: "Airport", width: 200, height: 200)
    ]
}
