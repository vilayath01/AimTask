//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel =  HomeViewModel()
    
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.tasks.isEmpty {
                    NoTasksView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(Dictionary(grouping: viewModel.tasks, by: { $0.locationName }).keys.sorted(), id: \.self) { locationName in
                                let tasksForLocation = viewModel.tasks.filter { $0.locationName == locationName }
                                let docIDsForLocation = tasksForLocation.map {$0.documentID}
                                TaskSectionView(title: locationName, tasks: tasksForLocation, docId: docIDsForLocation, viewModel: viewModel)
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
            viewModel.fetchTasks()
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
