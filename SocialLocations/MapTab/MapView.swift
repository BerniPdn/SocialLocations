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

    var friendUserId: String? = nil //optional friends filter
    var friendUsername: String? = nil
    
    @State private var searchModel = SearchViewModel()
    @StateObject private var pinsModel = PinsViewModel()
    @State private var pendingPinID: String?
    @State private var selectedPinID: String?
//    @State private var isSearchActive: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var friendsViewModel = FriendsViewModel()
    
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: FixedLocations.all[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    )
    
    @State private var isSheetPresented: Bool = true
    
    @ViewBuilder
    private func pinAnnotation(for pin: Pin) -> some View {
        Image("Paul")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .onTapGesture {
                selectedPinID = pin.id
            }
    }
    
    @ViewBuilder
    private func fixedAnnotation(for location: some Identifiable) -> some View {
        Image(location.imageName)
            .resizable()
            .frame(width: location.width, height: location.height)
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                ForEach(FixedLocations.all, id: \.name) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        fixedAnnotation(for: location)
                    }
                }
                
                ForEach(pinsModel.pins) { pin in
                    Annotation(pin.name, coordinate: pin.coordinate) {
                        pinAnnotation(for: pin)
                    }
                }
            }
            
            .mapStyle(.standard())
            .overlay(alignment: .top) {
                SearchOverlay(
                    query: $searchModel.query,
                    autoCompleteResults: searchModel.autoCompleteResults,
                    mapItems: searchModel.mapItems,
                    onSelectAutocomplete: { searchModel.search(for: $0) },
                    onSelectMapItem: { searchModel.select(item: $0) },
                    onClear: { isSearchFieldFocused = false }
                )
            }

            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .simultaneously(with: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        if let dragValue = value.second,
                           let coordinate = proxy.convert(dragValue.startLocation, from: .local) {
                            let tempID = UUID().uuidString
                            pinsModel.addLocalPin( coordinate: coordinate, id: tempID)
                            pendingPinID = tempID
                        }
                    }
            )

            .onChange(of: searchModel.selectedItem) {_, newItem in
                guard let newItem else { return }
                let coordinate = newItem.location.coordinate
                let tempID = UUID().uuidString
                pinsModel.addLocalPin(coordinate: coordinate, id: tempID)
                pendingPinID = tempID
//                isSearchActive = false
                isSearchFieldFocused = false
            }
            .onAppear { //filtering friends functionality
                pinsModel.listenToPins(friendIDs: friendsViewModel.friends.compactMap { $0.id })
            }
            .onChange(of: friendsViewModel.friends) { _, newFriends in
                pinsModel.listenToPins(friendIDs: newFriends.compactMap { $0.id })
            }
            
//            .sheet(isPresented: $isSearchActive) {
//                SearchSheet()
//                    .environment(searchModel)
//            }
            .sheet(isPresented: Binding(
                get: { pendingPinID != nil },
                set: { if !$0 {
                    if let id = pendingPinID {
                        pinsModel.removeLocalPin(id: id)
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
            .sheet(isPresented: Binding(
                get: { selectedPinID != nil },
                set: { if !$0 { selectedPinID = nil } }
            )) {
                if let id = selectedPinID {
                    InformationPinSheet(pinID: id, onDismiss: {
                        selectedPinID = nil
                    })
                    .environmentObject(pinsModel)
                }
            }
        }
    }
}

private struct SearchOverlay: View {
    @Binding var query: String
    var autoCompleteResults: [SearchResult]
    var mapItems: [MapItemResult]
    var onSelectAutocomplete: (String) -> Void
    var onSelectMapItem: (MKMapItem) -> Void
    var onClear: () -> Void
    //@FocusState private var isFocused: Bool

    private var showingResults: Bool {
        isFocused && (!autoCompleteResults.isEmpty || !mapItems.isEmpty)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search For A Location", text: $query)
                    .focused($isFocused)
                if !query.isEmpty {
                    Button {
                        query = ""
                        isFocused = false
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            if showingResults {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if mapItems.isEmpty {
                            ForEach(autoCompleteResults) { result in
                                Button { onSelectAutocomplete(result.title) } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.title).foregroundStyle(.primary)
                                        Text(result.subtitle).font(.caption).foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().padding(.leading, 12)
                            }
                        } else {
                            ForEach(mapItems) { result in
                                Button {
                                    onSelectMapItem(result.mapItem)
                                    isFocused = false
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.title).foregroundStyle(.primary)
                                        Text(result.subtitle).font(.caption).foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().padding(.leading, 12)
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .tint(.appDarkGreen)
    }
}

//#Preview {
//    MapView()
//}
