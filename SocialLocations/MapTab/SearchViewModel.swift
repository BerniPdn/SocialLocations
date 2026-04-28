//
//  SearchViewModel.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 3/30/26.
//

import MapKit
import SwiftUI

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

struct MapItemResult: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    var title: String { mapItem.name ?? "Unknown" }
    var subtitle: String { mapItem.address?.fullAddress ?? ""}
}

@Observable
class SearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    var query: String = "" {
        didSet {
            updateQuery()
        }
    }
    
    var autoCompleteResults = [SearchResult]()
    
    var mapItems: [MapItemResult] = []
    var region: MKCoordinateRegion?
    var selectedItem: MKMapItem?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
    }
    
    func updateQuery() {
        if query.isEmpty {
            autoCompleteResults = []
        } else {
            completer.queryFragment = query
            mapItems = []
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        autoCompleteResults = completer.results.map {
            SearchResult(title: $0.title, subtitle: $0.subtitle)
        }
    }
    
    func search(for query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        if let region {
            searchRequest.region = region
        }
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response else { return }
            Task {@MainActor in
                self.mapItems = response.mapItems.map {MapItemResult(mapItem: $0)}}
        }
    }
    
    func select(item: MKMapItem) {
        selectedItem = item
        mapItems = []
    }
    
}
