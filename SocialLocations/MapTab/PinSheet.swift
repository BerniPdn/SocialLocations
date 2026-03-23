//
//  PinSheet.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/9/26.
//

import SwiftUI
import MapKit

struct PinSheet: View {
    @EnvironmentObject var model: PinsViewModel
    
    var pinID: UUID
    var onDismiss: () -> Void
    
    private var pin: Pin? {model.pins.first(where: { $0.id == pinID })}
    
    @State private var name: String = ""
    @State private var rating: Int = 3
    @State private var comment: String = ""
    @State private var category: PinCategory = .other
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your newest discovery").font(.largeTitle)
            
            HStack {
                Text("ADDRESS").font(.headline)
                if let address = pin?.address {
                    Text(address).font(.subheadline)}
                else {
                    ProgressView().scaleEffect(0.7)
                }
            }
            
            Text("NAME").font(.headline)
            TextField("How is this cool (or uncool) place called?", text: $name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: name) { _, new in
                    if new.count > 50 { comment = String(new.prefix(50)) }
                }
            
            HStack {
                Text("RATING").font(.headline)
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { rating = star }
                }
            }
            
            Text("COMMENT").font(.headline)
            TextField("Your friends are counting on you. Spill it!", text: $comment, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
                .onChange(of: comment) { _, new in
                    if new.count > 150 { comment = String(new.prefix(150)) }
                }
            
            Text("CATEGORY").font(.headline)
            Picker("Category", selection: $category) {
                ForEach(PinCategory.allCases) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(.menu)
            .padding(20)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        
        Button(action: {
            guard let index = model.pins.firstIndex(where: { $0.id == pinID }) else {return}
            model.pins[index].name = name
            model.pins[index].comment = comment
            model.pins[index].rating = rating
            model.pins[index].category = category
            onDismiss()
        }) {
            Text("SAVE PIN")
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        .controlSize(.large)
    }
}
