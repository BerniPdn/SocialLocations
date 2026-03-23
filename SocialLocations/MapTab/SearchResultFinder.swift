//
//  SearchResultFinder.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 3/13/26.
//

import MapKit

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

@Observable
class SearchResultFinder: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    var results = [SearchResult]()
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }
    
    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }
    
    func completerDidUpdate(completer: MKLocalSearchCompleter) {
        results = completer.results.map { .init(title: $0.title, subtitle: $0.subtitle)}
    }
    
}
