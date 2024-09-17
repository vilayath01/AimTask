//
//  PostOnBoardingView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 17/9/2024.
//

import SwiftUI

enum PostOnboardingString {
    static let welcome = "welcome_title"
    static let description = "exploring_description"
    static let createButtonText = "create_button_text"
    static let exploreButtonText = "explore_button_text"
}

struct PostOnBoardingView: View {
    @State private var isNavigatingToMainApp = false
    @State private var isNavigatingToCreateAccount = false
    @EnvironmentObject var loginViewModel: LoginViewModel
    @Binding var showMainView: Bool
    @State private var showLoginView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                styledText(PostOnboardingString.welcome.localized)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                styledText(PostOnboardingString.description.localized, fontSize: 18)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                
                Button(action: {
                    loginViewModel.loginAnonymously()
                    showMainView = true
                }) {
                    styledText(PostOnboardingString.exploreButtonText.localized, fontSize: 16, isBold: false)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 20)
                
                Button(action: {
                    showLoginView = true
                }) {
                    styledText(PostOnboardingString.createButtonText.localized, fontSize: 16, isBold: false)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
                    .navigationDestination(isPresented: $isNavigatingToMainApp) {
                        MainApp(showMainView: $showMainView)
                    }
                
            }
            .background(Color.aimTaskBackground)
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
    }
}

#Preview {
    PostOnBoardingView(showMainView: .constant(false))
}
