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
    
    var pinID: String
    var onDismiss: () -> Void
    
    private var pin: Pin? {model.pins.first(where: { $0.id == pinID })}
    
    @State private var name: String = ""
    @State private var rating: Int = 3
    @State private var comment: String = ""
    @State private var category: PinCategory = .other
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Your newest discovery")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("LOCATION", systemImage: "mappin.and.ellipse")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                                
                HStack {
                    if let address = pin?.address {
                        Text(address)
                            .font(.callout)
                    } else {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Locating...").font(.caption).italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("NAME")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                TextField("How is this cool (or uncool) place called?", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: name) { _, new in
                        if new.count > 50 { comment = String(new.prefix(50)) }
                    }
            }
            
            HStack (spacing: 20) {
                Text("RATING").font(.headline)
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { rating = star }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("COMMENT")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                TextField("Your friends are counting on you. Spill it!", text: $comment, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: comment) { _, new in
                        if new.count > 150 { comment = String(new.prefix(150)) }
                    }
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
