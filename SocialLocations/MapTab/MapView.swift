//
//  MapView.swift
//  SocialLocationsUITests
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    //
    @StateObject private var pinsModel = PinsViewModel()
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var searchModel = SearchViewModel()
    @State private var pendingPinID: String? // ID of a pin being created before it is saved
    @State private var selectedPinID: String? // ID of a tapped pin - tiggers info sheet
    @FocusState private var isSearchFieldFocused: Bool
    @AppStorage("hasSeenMapTutorial") private var hasSeenMapTutorial = false
    @State private var showMapTutorial = false
    @State private var isSheetPresented: Bool = true
    @State private var savedCoordinate: CLLocationCoordinate2D? = nil
   
    // Initial camera position centered at Macalester College
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: FixedLocations.all[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    )
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $position) {
                    
                    // Landmark annotations
                    ForEach(FixedLocations.all, id: \.name) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Image(location.imageName)
                                .resizable()
                                .frame(width: location.width, height: location.height)
                        }
                    }
                    
                    // User and friend pins from Firestore
                    ForEach(pinsModel.pins) { pin in
                        Annotation(pin.name, coordinate: pin.coordinate) {
                            PinAnnotationView(pin: pin)
                                .onTapGesture {
                                    selectedPinID = pin.id
                                }
                        }
                    }
                }
                .mapStyle(.standard())
                .overlay(alignment: .top) {
                    SearchOverlay(
                        query: $searchModel.query,
                        autoCompleteResults: searchModel.autoCompleteResults,
                        mapItems: searchModel.mapItems,
                        onSelectAutocomplete: { searchModel.searchAndSelect(for: $0) },
                        onSelectMapItem: { searchModel.select(item: $0) },
                        onClear: { isSearchFieldFocused = false }
                    )
                }
                // Long press gesture to drop a Pin
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .simultaneously(with: DragGesture(minimumDistance: 0))
                        .onEnded { value in
                            if let dragValue = value.second,
                               let coordinate = proxy.convert(dragValue.startLocation, from: .local) {
                                let tempID = UUID().uuidString
                                pinsModel.addLocalPin(coordinate: coordinate, id: tempID)
                                pendingPinID = tempID
                            }
                        }
                )
                // Drop a Pin when the user selects a search result
                .onChange(of: searchModel.selectedItem) { _, newItem in
                    guard let newItem else { return }
                    let coordinate = newItem.location.coordinate
                    let tempID = UUID().uuidString
                    pinsModel.addLocalPin(coordinate: coordinate, id: tempID)
                    pendingPinID = tempID
                    isSearchFieldFocused = false
                }
                // Start listening to pins for the current user and their friends
                .onAppear {
                    pinsModel.listenToPins(friendIDs: friendsViewModel.friends.compactMap { $0.id })
                }
                // Trigger the tutorial on first launch
                .task {
                    guard !hasSeenMapTutorial else { return }
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    hasSeenMapTutorial = true
                    withAnimation { showMapTutorial = true }
                }
                // Change pins in map if Friends change
                .onChange(of: friendsViewModel.friends) { _, newFriends in
                    pinsModel.listenToPins(friendIDs: newFriends.compactMap { $0.id })
                }
                // Open sheet for saving new pin
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
                        }, onSave: { coordinate in
                            // Move the camera to the newly saved pin
                            withAnimation {
                                position = .region(MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                ))
                            }
                        })
                        .environmentObject(pinsModel)
                    }
                }
                // Open information sheet when tapping a pin
                .sheet(isPresented: Binding(
                    get: { selectedPinID != nil },
                    set: { if !$0 { selectedPinID = nil } }
                )) {
                    if let id = selectedPinID {
                        InformationPinSheet(pinID: id, onDismiss: {
                            selectedPinID = nil
                        })
                        .environmentObject(pinsModel)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
                }
            }
            // Show tutorial UI on first launch
            if showMapTutorial {
                TutorialOverlay(
                    message: "Long press then release to add a pin",
                    onDismiss: {
                        withAnimation { showMapTutorial = false }
                    }
                )
            }
        }
    }
}

// Display Search bar and result list at the top of the screen
private struct SearchOverlay: View {
    @Binding var query: String
    var autoCompleteResults: [SearchResult]
    var mapItems: [MapItemResult]
    var onSelectAutocomplete: (String) -> Void
    var onSelectMapItem: (MKMapItem) -> Void
    var onClear: () -> Void
    @FocusState private var isFocused: Bool
    
    private var showingResults: Bool {
        isFocused && (!autoCompleteResults.isEmpty || !mapItems.isEmpty)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
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
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brown, lineWidth: 3)
            )
            
            // Dropdown results
            if showingResults {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if mapItems.isEmpty {
                            // Autocomplete suggestions
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
                            // Full mao results
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

// Display the pin owner's profile photon the map
private struct PinAnnotationView: View {
    let pin: Pin
    @State private var profileImageURL: String? = nil

    var body: some View {
        Group {
            if let urlString = profileImageURL,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                // Fallback in case no profile pictire is set
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            // Fetch the pin owner's profile image from Firestore
            FirestoreManager.shared.fetchProfileImageURL(for: pin.userId) { result in
                if case .success(let url) = result {
                    profileImageURL = url
                }
            }
        }
    }
}

