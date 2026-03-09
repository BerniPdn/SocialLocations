//
//  MapView.swift
//  SocialLocationsUITests
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var pinsModel = PinsModel()
    
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
                
                ForEach(pinsModel.pins) {pin in
                    Annotation(pin.name, coordinate: pin.coordinate) {
                        VStack{
                            Image("Paul")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            if let address = pin.address {
                                Text(address)
                                    .font(.custom("Times New Roman", fixedSize: 10))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                            } else {
                                Text("Loading…")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard())
            .onTapGesture { screenPoint in
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    Task {
                        await pinsModel.savePin(coordinate: coordinate, name: "", comment: "", rating: 0) //I have to find a way so that the user can add this infomation, and then when you press an Pin you can see it
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
}
