//
//  AimTaskApp.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 20/7/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct AimTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var isPrivacyScreenVisible = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainApp()
                    .environmentObject(loginViewModel)
                
                if isPrivacyScreenVisible {
                    PrivacyView()
                        .transition(.opacity)
                }
            }
          
            .onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)) { _ in
             
                isPrivacyScreenVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
              
                isPrivacyScreenVisible = false
            }
        }
    }
}

