//
//  SheetView.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 3/9/26.
//

import MapKit
import SwiftUI

struct SearchSheet: View {
    @State private var search: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var searchResultFinder = SearchResultFinder(completer: .init())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search For A Location", text: $search)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                
                if !search.isEmpty {
                    Button {
                        search = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            
            List {
                ForEach(searchResultFinder.results) { SearchResult in
                    Button(action: { }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(SearchResult.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(SearchResult.subtitle)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .onChange(of: search) {
            searchResultFinder.update(queryFragment: search)
        }
        .padding(10)
        .presentationDetents([.height(80), .medium])
        .presentationBackground(.clear)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
        .interactiveDismissDisabled(true)
    }
}
