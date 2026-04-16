//
//  InformationPinSheet.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 4/1/26.
//

import MapKit
import SwiftUI


struct InformationPinSheet: View {
    @EnvironmentObject var model: PinsViewModel
    @State private var isEditing = false
    
    var pinID: String
    var onDismiss: () -> Void
    
    private var pin: Pin? {
        model.pins.first(where: { $0.id == pinID })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            // HEADING
            Text(pin?.name ?? "Unknown Place")
                .font(.system(.title, design: .rounded))
                .fontWeight(.semibold)
            
            //ADDRESS SECTION
            VStack(alignment: .leading, spacing: 8) {
                Label("LOCATION", systemImage: "mappin.and.ellipse")
                    .font(.subheadline.bold())
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
            }
            
            Divider()
            
            //RATING AND CATEGORY SECTIONS
                VStack(alignment: .leading, spacing: 8){
                    Label("RATING", systemImage: "star.leadinghalf.filled")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4){
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= (pin?.rating ?? 0) ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.title3)
                        }
                    }
                }
            
            Divider()
                
            VStack(alignment: .leading, spacing: 8){
                Label("CATEGORY", systemImage: "tag.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Text(pin?.category.rawValue ?? "")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            //COMMENT SECTION
            VStack(alignment: .leading, spacing: 8) {
                Label("COMMENT", systemImage: "message.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Text(pin?.comment ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack (spacing: 40){
                Button(action: {
                    isEditing = true
                }) {
                    Label("Edit", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button(action: {
                    model.deletePin(pinID: pinID)
                    onDismiss()
                }) {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }

        .task {
            await model.lookupAddress(for: pinID)
        }
        .dynamicTypeSize(.xxxLarge)
        .padding(.horizontal, 24)
        .sheet(isPresented: $isEditing) {
            if let pin = pin {
                EditPinView(pin: pin)
                    .environmentObject(model)
            }
        }
    }
}
