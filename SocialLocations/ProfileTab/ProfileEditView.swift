//
//  ProfileEditView.swift
//  SocialLocations
//
//  Created by Silas Revenaugh on 4/28/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var isUploading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack{
            ZStack{
                AppBackground()
                
                VStack(spacing: 15) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                          if let uiImage = selectedUIImage {
                             Image(uiImage: uiImage)
                                  .resizable()
                                  .scaledToFill()
                                  .frame(width: 120, height: 120)
                                  .clipShape(Circle())
                        } else if let urlString = authViewModel.appUser?.profileImageURL,
                                    !urlString.isEmpty,
                                    let url = URL(string: urlString) {
                          // Show existing saved photo while no new one is picked
                              AsyncImage(url: url) { image in
                                   image.resizable().scaledToFill()
                              } placeholder: {
                                   ProgressView()
                              }
                              .frame(width: 200, height: 200)
                              .clipShape(Circle())
                       } else {
                          Image(systemName: "person.crop.circle.fill")
                              .resizable()
                              .frame(width: 200, height: 200)
                              .foregroundColor(.gray)
                      }
            }
                    
                    TextField("Username", text: $username)
                        .sheetTextFieldStyle()
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button {
                        saveProfile()
                    } label: {
                        if isUploading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Confirm Profile Changes")
                        }
                    }
                    
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isUploading)
                }
                .navigationTitle("Edit Profile")
                .onAppear {
                    username = authViewModel.appUser?.username ?? ""
                    phoneNumber = authViewModel.appUser?.phoneNumber ?? ""
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let item = selectedItem,
                           let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedUIImage = uiImage
                        }
                    }
                    
                }
                .dynamicTypeSize(.xxLarge)
                .padding(.horizontal, 24)
                .padding(.vertical, 15)
            }
        }
    }
    
    private func saveProfile() {
            isUploading = true
            errorMessage = ""
        

    // If a new image was picked, upload it first
            if let uiImage = selectedUIImage,
                   let imageData = uiImage.jpegData(compressionQuality: 0.7) {

                    StorageManager.shared.uploadProfileImage(imageData) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let url):
                                authViewModel.updateProfile(
                                    username: username,
                                    phoneNumber: phoneNumber,
                                    profileImageURL: url        // pass the new URL
                                ) { success in
                                    isUploading = false
                                    if success { dismiss() }
                                    else { errorMessage = authViewModel.errorMessage }
                                }
                            case .failure(let error):
                                isUploading = false
                                errorMessage = error.localizedDescription
                            }
                        }
                    }

                } else {
                    // No new image — just save username/phone, keep existing URL
                    authViewModel.updateProfile(
                        username: username,
                        phoneNumber: phoneNumber,
                        profileImageURL: authViewModel.appUser?.profileImageURL ?? ""
                    ) { success in
                        isUploading = false
                        if success { dismiss() }
                        else { errorMessage = authViewModel.errorMessage }
                    }
                }
            }
}







