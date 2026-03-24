//
//  SocialLocationsApp.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configured successfully!") // CHECK: will print in the terminal when the build can run successfully (no errors left)

    return true	
  }
}
	
@main
struct SocialLocationsApp: App {
    
    // Attach Firebase AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
