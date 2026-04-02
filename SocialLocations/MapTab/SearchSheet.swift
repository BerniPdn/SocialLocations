//
//  SheetView.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 3/9/26.
//

import MapKit
import SwiftUI

struct SearchSheet: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    @FocusState private var isSearchFocused: Bool
    
    private var showingResults: Bool {
        isSearchFocused && !searchViewModel.autoCompleteResults.isEmpty
    }
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        VStack(alignment: .leading, spacing: 12) {
            //Search Bar
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.primary)
                TextField("Search For A Location", text: $searchViewModel.query)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                
                if !searchViewModel.query.isEmpty {
                    Button {
                        searchViewModel.query = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(5)
            .background(.ultraThinMaterial)
            
            if showingResults {
                ScrollView() {
                    if searchViewModel.mapItems.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(searchViewModel.autoCompleteResults){ result in
                            Button {
                                searchViewModel.search(for: result.title)
                            } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(result.title)
                                        .foregroundStyle(.primary)
                                    Text(result.subtitle)
                                        .foregroundStyle(.secondary)
                                }
                            }
                                .padding(5)
                                
                            }
                        }
                    } else {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(searchViewModel.mapItems){ result in
                                Button {
                                    searchViewModel.select(item: result.mapItem)
                                } label: {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(result.title)
                                            .foregroundStyle(.primary)
                                        Text(result.subtitle)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                    .padding(5)
                                    
                                }
                            }
                    }
                }
            }
            
            
        }
        .padding(5)
        .padding(.horizontal, 24)
        .presentationDetents(showingResults ? [.medium] : [.height(80)])
        .presentationBackground(.clear)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
        .interactiveDismissDisabled(false)
    }

}
