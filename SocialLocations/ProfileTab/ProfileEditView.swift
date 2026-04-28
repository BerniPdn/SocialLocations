//
//  ProfileEditView.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 4/28/26.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let selectedPhoto = selectedImage {
                        selectedPhoto
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                }
                TextField("Username", text: $username)
                TextField("Phone Number", text: $phoneNumber)
                Button {
                    authViewModel.updateProfile(username: username, phoneNumber: phoneNumber)
                } label: {
                    Text("Confirm Profile Changes")
                    
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                username = authViewModel.appUser?.username ?? ""
                phoneNumber = authViewModel.appUser?.phoneNumber ?? ""
            }
            .onChange(of: selectedItem) {_, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Image.self) {
                        selectedImage = data
                    }
                }
                
            }
        }
    }
}







