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
            VStack(alignment: .leading, spacing: 25) {
                // HEADING
                Text("Your newest discovery")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
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
                
                //NAME SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Text("NAME")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    TextField("How is this place called?", text: $name)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .onChange(of: name) { _, new in
                            if new.count > 50 { comment = String(new.prefix(50)) }
                        }
                }
                //RATING AND CATEGORY SECTIONS
                HStack (spacing: 20) {
                    VStack(alignment: .leading, spacing: 8){
                        Text("RATING")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing:4){
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                                    .font(.title3)
                                    .onTapGesture {
                                        withAnimation(.spring()){
                                            rating = star }
                                    }
                            }
                        }
                    }
                    
                    Spacer()
                    VStack(alignment: .leading, spacing: 8){
                        Text("CATEGORY")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        
                        Picker("Category", selection: $category) {
                            ForEach(PinCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                
                //COMMENT SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Text("COMMENT")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    TextField("Spill it!", text: $comment, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
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
                    Text("SAVE PIN")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .dynamicTypeSize(.xxLarge)
            .padding(.horizontal, 24)
            
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
