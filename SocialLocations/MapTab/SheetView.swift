//
//  SheetView.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 3/9/26.
//

import MapKit
import SwiftUI

struct SheetView: View {
    @State private var search: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search For A Location", text: $search)
            }
            
            Spacer()
        }
        .padding()
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}
