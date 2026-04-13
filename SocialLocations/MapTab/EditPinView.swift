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
        VStack(spacing: 20) {
            
            Text("Edit Pin")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Name", text: $pin.name)
                .textFieldStyle(.roundedBorder)
            
            TextField("Comment", text: $pin.comment)
                .textFieldStyle(.roundedBorder)
            
            Stepper("Rating: \(pin.rating)", value: $pin.rating, in: 0...5)
            
            Button(action: {
                model.updatePin(pin: pin)
                dismiss()
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}
