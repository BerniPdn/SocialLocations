//
//  PinSheet.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/9/26.
//

import SwiftUI
import MapKit

struct PinSheet: View {
    var coordinate: CLLocationCoordinate2D
    var onSave: (Pin) -> Void
    
    @State private var name: String = ""
    @State private var rating: Int = 3
    @State private var comment: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your newest discovery").font(.largeTitle)
            HStack {
                Text("Address:").font(.headline)
                Text("Place's address").font(.subheadline) //I have to figure out how to use lookup so that each pin has their own address - this is justto test how it would look
            }
            
            Text("Name:").font(.headline)
            TextField("How is this cool (or uncool) place called?", text: $name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: name) { _, new in
                        if new.count > 50 { comment = String(new.prefix(50)) }
                    }
            
            HStack {
                Text("Rating:").font(.headline)
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { rating = star }
                }
            }
            
            Text("Comment:").font(.headline)
            TextField("Your friends are counting on you. Spill it!", text: $comment, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...3)
                .onChange(of: comment) { _, new in
                        if new.count > 150 { comment = String(new.prefix(150)) }
                    }
            
            Button("Save Pin") {
                let pin = Pin(
                    coordinate: coordinate,
                    name: name,
                    comment: comment,
                    rating: rating)
                onSave(pin)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium])
    }
}
