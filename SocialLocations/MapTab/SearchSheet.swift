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
    @State private var searchResultFinder = SearchResultFinder()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            //Search Bar
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
            
            if isSearchFocused && !searchResultFinder.results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(searchResultFinder.results){ result in
                            Button {
                                
                            } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(result.title)
                                        .foregroundStyle(.primary)
                                    Text(result.subtitle)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(10)
                                
                            }
                        }
                    }
                }
            }
            
            
        }
        .padding(10)
        .onChange(of: search) { _, newValue in
            searchResultFinder.update(queryFragment: newValue)
        }
        .presentationDetents([.height(80), .medium])
        .presentationBackground(.clear)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
        .interactiveDismissDisabled(true)
    }
}
