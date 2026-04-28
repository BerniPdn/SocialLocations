//
//  EditPinView.swift
//  SocialLocations
//
//  Created by Shahd Zahayka on 4/12/26.
//

import SwiftUI

struct EditPinView: View {
    @EnvironmentObject var model: PinsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var pin: Pin
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(alignment: .leading, spacing: 35) {
                
                // HEADING
                Text("Edit Your Existing Pin")
                    .sheetTitleStyle()
                
                //Display Location - you can't edit this
                VStack(alignment: .leading, spacing: 8) {
                    Label("LOCATION", systemImage: "mappin.and.ellipse")
                        .sheetSubtitleStyle()
                    
                    HStack {
                        if let address = pin.address {
                            Text(address)
                                .font(.callout)
                        } else {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Locating...").font(.caption).italic()
                        }
                    }
                    .sheetTextFieldStyle()
                }
                
                //NAME SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Label("NAME", systemImage: "signpost.right")
                        .sheetSubtitleStyle()
                    
                    TextField("Name", text: $pin.name)
                        .onChange(of: pin.name) { _, new in
                            if new.count > 50 { pin.name = String(new.prefix(50)) }
                        }
                        .sheetTextFieldStyle()
                }
                
                //RATING AND COMMENTING SECTION
                HStack (spacing: 20) {
                    VStack(alignment: .leading, spacing: 8){
                        Label("RATING", systemImage: "star.leadinghalf.fill")
                            .sheetSubtitleStyle()
                        
                        HStack(spacing:4){
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= pin.rating ? "star.fill" : "star")
                                    .sheetStarStyle()
                                    .onTapGesture {
                                        withAnimation(.spring()){
                                            pin.rating = star }
                                    }
                            }
                        }
                        .sheetRatingTextFieldStyle()
                    }
                    
                    VStack(alignment: .leading, spacing: 8){
                        Label("CATEGORY", systemImage: "tag.fill")
                            .sheetSubtitleStyle()
                        
                        Picker("Category", selection: $pin.category) {
                            ForEach(PinCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .sheetCategoryTextFieldStyle()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("COMMENT", systemImage: "message.fill")
                        .sheetSubtitleStyle()
                    
                    TextField("Comment", text: $pin.comment, axis: .vertical)
                        .lineLimit(3...5)
                        .sheetTextFieldStyle()
                        .toolbar {  //temporary solution for dismissing keyboard
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done writting!") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }
                        .onChange(of: pin.comment) { _, new in
                            if new.count > 150 { pin.comment = String(new.prefix(150)) }
                        }
                }
                
                Button(action: {
                    model.updatePin(pin: pin)
                    dismiss()
                }) {
                    Text("Save Changes")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .dynamicTypeSize(.xxLarge)
            .padding(.horizontal, 24)
        }
    }
}

