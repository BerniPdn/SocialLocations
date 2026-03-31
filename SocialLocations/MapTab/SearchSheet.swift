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
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        VStack(alignment: .leading, spacing: 12) {
            //Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
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
            .padding(10)
            .background(.ultraThinMaterial)
            
            if isSearchFocused && !searchViewModel.autoCompleteResults.isEmpty {
                ScrollView {
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
                                .padding(10)
                                
                            }
                        }
                    }
                }
            }
            
            
        }
        .padding(10)
        .presentationDetents([.height(80), .medium])
        .presentationBackground(.clear)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
        .interactiveDismissDisabled(true)
    }

}
