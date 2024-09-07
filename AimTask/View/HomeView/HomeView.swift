//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if !viewModel.errorMessage.isEmpty {
                        ErrorBarView(errorMessage: $viewModel.errorMessage, isPositive: $viewModel.isPositive)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: viewModel.errorMessage)
                    }
                    if viewModel.tasks.isEmpty {
                        Spacer()
                        NoTasksView(taskViewToShow: true)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(Dictionary(grouping: viewModel.tasks, by: { $0.locationName }).keys.sorted(), id: \.self) { locationName in
                                    let tasksForLocation = viewModel.tasks.filter { $0.locationName == locationName }
                                    let docIDsForLocation = tasksForLocation.map { $0.documentID }
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
            
            // Overlay the "Something Went Wrong" card
            if showSomethingWentWrong {
                SomethingWentWrongView(retryAction: {
                    if networkMonitor.isConnected {
                        showSomethingWentWrong = false
                    } else {
                        print("Network is still down!")
                    }
                })
                .transition(.scale)
                .padding()
            }
        }
        .animation(.easeInOut, value: showSomethingWentWrong)
        .onReceive(networkMonitor.$isConnected) { isConnected in
            print("Network status changed: \(isConnected)")
            showSomethingWentWrong = !isConnected
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LoginViewModel())
    }
}
