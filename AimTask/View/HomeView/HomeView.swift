//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var fdbManager = FDBManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if fdbManager.tasks.isEmpty {
                    NoTasksView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(Dictionary(grouping: fdbManager.tasks, by: { $0.locationName }).keys.sorted(), id: \.self) { locationName in
                                let tasksForLocation = fdbManager.tasks.filter { $0.locationName == locationName }
                                TaskSectionView(title: locationName, tasks: tasksForLocation)
                            }
                        }
                        .padding(.top)
                    }
                    
                }
            }
            .navigationTitle("Home: \(loginViewModel.displayName.usernameFromEmail())")
            .background(Color(red: 105/255, green: 155/255, blue: 157/255).ignoresSafeArea())
           
        }
        .onAppear {
            fdbManager.fetchTasks()
        }
    }
}

// Preview for SwiftUI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LoginViewModel()) // Mocked LoginViewModel
    }
}
