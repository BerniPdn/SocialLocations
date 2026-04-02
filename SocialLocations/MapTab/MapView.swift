//
//  MapView.swift
//  SocialLocationsUITests
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import MapKit
//extension UUID: @retroactive Identifiable {
//    public var id: UUID { self }
//}

struct MapView: View {
    @State private var searchModel = SearchViewModel()
    @StateObject private var pinsModel = PinsViewModel()
    @State private var pendingPinID: String?
    @State private var isPinDroppingActive: Bool = false
    @State private var isSearchActive: Bool = false
    
    
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
            
            .mapStyle(.standard())
            .overlay(alignment: .topTrailing) {
                Button {
                    isPinDroppingActive.toggle()
                    if isSearchActive {
                        isSearchActive.toggle()
                    }
                } label: {
                    Image(systemName: isPinDroppingActive ? "mappin.slash" : "mappin.circle.fill")
                        .padding()
                        .foregroundStyle(isPinDroppingActive ? .red: .primary)
                }
                .buttonStyle(.bordered)
                .tint(.black)
                .padding(.top, 175)
                
                Button {
                    isSearchActive.toggle()
                    if isPinDroppingActive {
                        isPinDroppingActive.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass.circle")
                        .padding()
                        .foregroundStyle(isSearchActive ? .red: .primary)
                }
                .buttonStyle(.bordered)
                .tint(.black)
            }
            .onTapGesture { screenPoint in
                guard isPinDroppingActive else { return }
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    let tempID = UUID().uuidString
                    pinsModel.addLocalPin( coordinate: coordinate, id: tempID)
                    pendingPinID = tempID
                    isPinDroppingActive = false
                }
            }
            .onChange(of: searchModel.selectedItem) {_, newItem in
                guard let newItem else { return }
                let coordinate = newItem.location.coordinate
                let tempID = UUID().uuidString
                pinsModel.addLocalPin(coordinate: coordinate, id: tempID)
                pendingPinID = tempID
                isSearchActive = false
            }
            
            .sheet(isPresented: $isSearchActive) {
                SearchSheet()
                    .environment(searchModel)
            }
            .sheet(isPresented: Binding(
                            get: { pendingPinID != nil },
                            set: { if !$0 {
                                if let id = pendingPinID {
                                    pinsModel.removeLocalPin(id: id) // ← add this
                                }
                                pendingPinID = nil
                            }}
                        )) {
                            if let id = pendingPinID {
                                NewPinSheet(pinID: id, onDismiss: {
                                    pendingPinID = nil
                                })
                                .environmentObject(pinsModel)
                            }
                        }
                    }
                }
            }

#Preview {
    MapView()
}
