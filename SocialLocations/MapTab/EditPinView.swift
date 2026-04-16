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
        VStack(alignment: .leading, spacing: 35) {
            
            // HEADING
            Text("Edit Your Existing Pin")
                .font(.system(.title, design: .rounded))
                .fontWeight(.semibold)
            
            //Display Location - you can't edit this
            VStack(alignment: .leading, spacing: 8) {
                Label("LOCATION", systemImage: "mappin.and.ellipse")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

            }
            
            //NAME SECTION
            VStack(alignment: .leading, spacing: 8) {
                Label("NAME", systemImage: "signpost.right")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                TextField("Name", text: $pin.name)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: pin.name) { _, new in
                        if new.count > 50 { pin.name = String(new.prefix(50)) }
                    }
            }
            
            //RATING AND COMMENTING SECTION
            HStack (spacing: 20) {
                VStack(alignment: .leading, spacing: 8){
                    Label("RATING", systemImage: "star.leadinghalf.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing:4){
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= pin.rating ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                                .font(.title3)
                                .onTapGesture {
                                    withAnimation(.spring()){
                                        pin.rating = star }
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8){
                    Label("CATEGORY", systemImage: "tag.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    Picker("Category", selection: $pin.category) {
                        ForEach(PinCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 140)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("COMMENT", systemImage: "message.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                TextField("Comment", text: $pin.comment, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
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
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .dynamicTypeSize(.xxLarge)
        .padding(.horizontal, 24)
    }
}

