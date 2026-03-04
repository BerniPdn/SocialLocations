//
//  MapView.swift
//  SocialLocationsUITests
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var userDroppedPins: [CLLocationCoordinate2D] = []
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: FixedLocations.all[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    )
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                ForEach(FixedLocations.all, id: \.name) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        Image(location.imageName)
                            .resizable()
                            .frame(width: location.width, height: location.height)
                    }
                }
                
                ForEach(userDroppedPins.indices, id: \.self) { index in
                    Marker("Pin \(index + 1)", systemImage: "person.fill", coordinate: userDroppedPins[index])
                        .tint(.red)
                }
            }
            .onTapGesture { screenPoint in
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    userDroppedPins.append(coordinate)
                }
            }
                .mapStyle(.standard())
            }
        }
    }

#Preview {
    MapView()
}
