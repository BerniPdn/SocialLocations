//
//  SocialLocationsApp.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

//import SwiftUI
//import FirebaseCore
//import FirebaseAuth
//import FirebaseFirestore
//
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true	
//  }
//}
//	
//@main
//struct SocialLocationsApp: App {
//    
//    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Attach Firebase AppDelegate
//    @StateObject private var authViewModel = AuthViewModel() // Needed for authentication
//    
//    var body: some Scene {
//        WindowGroup {
//            //MainView()
//            RootView().environmentObject(authViewModel)
//        }
//    }
//}
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured successfully!")
        return true
    }
}

@main
struct SocialLocationsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
