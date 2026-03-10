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
    @State private var pendingPin: Pin?
    @State private var isPinDroppingActive: Bool = false
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: FixedLocations.all[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    )
    
    @State private var isSheetPresented: Bool = true
    
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
                        }
                    }
                }
            }
            //This is the code for my sheet view for searching that isn't working yet
//            .ignoresSafeArea()
//            .sheet(isPresented: $isSheetPresented) {
//                SearchSheet()
//            }
            .mapStyle(.standard())
            .overlay(alignment: .topTrailing) {
                Button {
                    isPinDroppingActive.toggle()
                } label: {
                    Image(systemName: isPinDroppingActive ? "mappin.slash" : "mappin.circle.fill")
                        .padding()
                        .foregroundStyle(isPinDroppingActive ? .red: .primary)
                        .background(.ultraThinMaterial)
                }
                .frame(width: 50, height: 100)
                .padding(.top, 175)
            }
            .onTapGesture { screenPoint in
                guard isPinDroppingActive else { return }
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    pendingPin =  Pin(coordinate: coordinate, name: "", comment: "", rating: 0)
                    isPinDroppingActive = false
                }
            }
            .sheet(item: $pendingPin) {pin in
                PinSheet(coordinate: pin.coordinate) {newPin in
                    Task{
                        await pinsModel.savePin(
                            coordinate: newPin.coordinate,
                            name: newPin.name,
                            comment: newPin.comment,
                            rating: newPin.rating)
                    }
                    pendingPin = nil
                }
            }
        }
    }
}

#Preview {
    MapView()
}
