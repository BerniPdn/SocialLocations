//
//  StorageManager.swift
//  SocialLocations
//
//  Created by Shahed Zahaykeh on 5/5/26.
//


import Foundation
import FirebaseStorage
import FirebaseAuth

class StorageManager {
    static let shared = StorageManager()
    private init() {}

    func uploadProfileImage(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Storage.storage().reference().child("profile_pictures/\(uid)")

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
}
