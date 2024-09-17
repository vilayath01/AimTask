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
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.clear
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var isPrivacyScreenVisible = false
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false
    @AppStorage("showMainView")
    private var showMainView = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if loginViewModel.authenticationState == .authenticated {
                          MainApp(showMainView: $showMainView)
                              .environmentObject(loginViewModel)
                      } else if hasCompletedOnboarding {
                          PostOnBoardingView(showMainView: $showMainView)
                              .environmentObject(loginViewModel)
                      } else {
                          OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                      }

                if isPrivacyScreenVisible {
                    PrivacyView()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: isPrivacyScreenVisible)
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

