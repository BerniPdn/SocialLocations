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
    
    var pinID: String
    var onDismiss: () -> Void
    
    private var pin: Pin? {
        model.pins.first(where: { $0.id == pinID })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            // HEADING
            Text(pin?.name ?? "Unknown Place")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
            
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
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            //RATING AND CATEGORY SECTIONS
            HStack (spacing: 8) {
                VStack(alignment: .leading, spacing: 8){
                    Text("RATING")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing:4){
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= (pin?.rating ?? 0) ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.title3)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8){
                Text("CATEGORY")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Text(pin?.category.rawValue ?? "")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            //COMMENT SECTION
            VStack(alignment: .leading, spacing: 8) {
                Text("COMMENT")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Text(pin?.comment ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        
        .task {
            await model.lookupAddress(for: pinID)
        }
        .dynamicTypeSize(.accessibility1)
        .padding(.horizontal, 24)
    }
}

