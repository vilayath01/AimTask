//
//  OnboardingView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 9/9/2024.
//

import Foundation
import SwiftUI

enum Onboarding {

    static let onboardingWelcomeTitle = "onboarding_welcome_title"
    static let onboardingWelcomeDescription = "onboarding_welcome_description"
    static let addTaskToCompleteTitle = "onboarding_task_complete_title"
    static let addTaskToCompleteDescription = "onboarding_task_complete_description"
    static let emailTitle = "onboarding_email_title"
    static let emailDescription = "onboarding_email_description"
    static let finalTitle = "onboarding_final_title"
    static let finalDescription = "onboarding_final_description"
    static let letsBeginButton = "onboarding_lets_begin_button"
    
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        TabView {
            WelcomeScreen()
            TaskCompleteScreen()
            EmailScreen()
            OnboardingFinalScreen(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color(red: 105/255, green: 155/255, blue: 157/255))
        .ignoresSafeArea()
    }
}

struct WelcomeScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 200)
            
            
            styledText(Onboarding.onboardingWelcomeTitle.localized)
                
                .multilineTextAlignment(.center)
            
            styledText(Onboarding.onboardingWelcomeDescription.localized, fontSize: 18)
              
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct TaskCompleteScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("map")
                .resizable()
                .frame(width: 300, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
            
           styledText(Onboarding.addTaskToCompleteTitle.localized)
                
                .multilineTextAlignment(.center)
            
           styledText(Onboarding.addTaskToCompleteDescription.localized, fontSize: 18)
                
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct EmailScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("emails")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .padding(.bottom, 40)
            
            styledText(Onboarding.emailTitle.localized)
               
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            styledText(Onboarding.emailDescription.localized, fontSize: 18)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingFinalScreen: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            styledText(Onboarding.finalTitle.localized)
                
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            styledText(Onboarding.finalDescription.localized, fontSize: 18)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            Image("confetti")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .padding(.bottom, 40)
            
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                styledText(Onboarding.letsBeginButton.localized,fontSize: 18, isBold: false)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
