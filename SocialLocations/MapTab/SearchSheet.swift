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
            
        }
        .padding(10)
        .presentationDetents([.height(80), .medium])
        .presentationBackground(.clear)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
        .interactiveDismissDisabled(true)
    }
}
