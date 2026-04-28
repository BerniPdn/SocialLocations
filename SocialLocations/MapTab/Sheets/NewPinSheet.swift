//
//  PinSheet.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/9/26.
//

import SwiftUI
import MapKit

struct NewPinSheet: View {
    @EnvironmentObject var model: PinsViewModel
    
    var pinID: String
    var onDismiss: () -> Void
    
    private var pin: Pin? {
        model.pins.first(where: { $0.id == pinID })
    }
    
    @State private var name: String = ""
    @State private var rating: Int = 3
    @State private var comment: String = ""
    @State private var category: PinCategory = .other
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(alignment: .leading, spacing: 35) {
                    // HEADING
                    Text("Your newest discovery")
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
                        .sheetTextFieldStyle()
                    }
                    
                    //NAME SECTION
                    VStack(alignment: .leading, spacing: 8) {
                        Label("NAME", systemImage: "signpost.right")
                            .sheetSubtitleStyle()
                        
                        TextField("How is this place called?", text: $name)
                            .sheetTextFieldStyle()
                            .onChange(of: name) { _, new in
                                if new.count > 50 { name = String(new.prefix(50)) }
                            }
                    }
                    //RATING AND CATEGORY SECTIONS
                    HStack (spacing: 20) {
                        VStack(alignment: .leading, spacing: 8){
                            Label("RATING", systemImage: "star.leadinghalf.fill")
                                .sheetSubtitleStyle()
                            
                            HStack(spacing:4){
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .sheetStarStyle()
                                        .onTapGesture {
                                            withAnimation(.spring()){
                                                rating = star }
                                        }
                                }
                            }
                            .sheetRatingTextFieldStyle()
                        }
                        
                        Spacer()
                        VStack(alignment: .leading, spacing: 8){
                            Label("CATEGORY", systemImage: "tag.fill")
                                .sheetSubtitleStyle()
                        
                            Picker("Category", selection: $category) {
                                ForEach(PinCategory.allCases, id: \.self) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .sheetCategoryTextFieldStyle()
                        }
                    }
                    
                    //COMMENT SECTION
                    VStack(alignment: .leading, spacing: 8) {
                        Label("COMMENT", systemImage: "message.fill")
                            .sheetSubtitleStyle()
                        
                        TextField("Spill it!", text: $comment, axis: .vertical)
                            .sheetTextFieldStyle()
                            .lineLimit(3...5)
                            .toolbar {  //temporary solution for dismissing keyboard
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done writting!") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                            .onChange(of: comment) { _, new in
                                if new.count > 150 { comment = String(new.prefix(150)) }
                            }
                    }
                    
                    .task {
                        await model.lookupAddress(for: pinID)
                    }
                    
                    Button(action: {
                        saveAndDismiss()
                    }) {
                        Text("Save")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .dynamicTypeSize(.xxLarge)
                .padding(.horizontal, 24)
                
            }
        }
    }
    
    private func saveAndDismiss() {
        guard let currentPin = pin,
              let index = model.pins.firstIndex(where: { $0.id == pinID }) else { return }
        
        model.pins[index].name = name
        model.pins[index].comment = comment
        model.pins[index].rating = rating
        model.pins[index].category = category
        
        model.savePin(
            coordinate: currentPin.coordinate,
            name: name,
            comment: comment,
            rating: rating,
            category: category,
            id: pinID
        )
        
        onDismiss()
    }
}
