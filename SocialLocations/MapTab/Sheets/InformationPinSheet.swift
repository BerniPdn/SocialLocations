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
        ZStack {
            AppBackground()
            
            VStack(alignment: .leading, spacing: 35) {
                // HEADING
                Text(pin?.name ?? "Unknown Place")
                    .sheetTitleStyle()
                
                //ADDRESS SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Label("LOCATION", systemImage: "mappin.and.ellipse")
                        .sheetSubtitleStyle()
                    
                    HStack {
                        if let address = pin?.address {
                            Text(address)
                                .sheetTextStyle()
                        } else {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Locating...").font(.caption).italic()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                //RATING AND CATEGORY SECTIONS
                VStack(alignment: .leading, spacing: 8){
                    Label("RATING", systemImage: "star.leadinghalf.filled")
                        .sheetSubtitleStyle()
                    
                    HStack(spacing: 4){
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= (pin?.rating ?? 0) ? "star.fill" : "star")
                                .sheetStarStyle()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8){
                    Label("CATEGORY", systemImage: "tag.fill")
                        .sheetSubtitleStyle()
                    
                    Text(pin?.category.rawValue ?? "")
                        .sheetCapsuleStyle()
                }
                
                //COMMENT SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Label("COMMENT", systemImage: "message.fill")
                        .sheetSubtitleStyle()
                    
                    Text(pin?.comment ?? "")
                        .sheetTextStyle()
                }
                
                //BUTTONS
                HStack (spacing: 40){
                    Button(action: {
                        isEditing = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(action: {
                        model.deletePin(pinID: pinID)
                        onDismiss()
                    }) {
                        Label("Delete", systemImage: "mappin.slash")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(DestructiveButtonStyle())
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
}
