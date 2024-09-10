//
//  OnboardingView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 9/9/2024.
//

import Foundation
import SwiftUI

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
           
            
            Text("Welcome to Aim Task!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("""
            Your personal task manager that helps you stay organized. Complete tasks effortlessly with geofence technology, receiving notifications as you enter or leave specific locations so you never miss a task. Create an anonymous account easily—no need to use your actual email.
            """)
                .font(.title3)
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
            
            Text("Add Task to Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("""
            Create location-based tasks by pressing the ‘+’ button. Set the geofence on the map and save. Whenever you pass by that location, a notification will remind you of the tasks you need to complete there. Ensure location permissions are always enabled for geofencing to work properly.
            """)
                .font(.title3)
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
            
            Text("Send a Completed Task via Email")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("""
            After completing a task, save it to your history by tapping the green checkmark in the home tab. Then, select the task you want to send via email to your friend or colleague.
            """)
                .font(.title3)
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
            
            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Text("You're ready to start using Aim Task to stay organized and productive.")
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
                Text("Let's Begin")
                    .font(.title2)
                    .fontWeight(.semibold)
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
