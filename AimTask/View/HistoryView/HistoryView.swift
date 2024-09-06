//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var historyViewModel = HistoryViewModel(loginViewModel: LoginViewModel())
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    @State private var enteredEmail: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if !historyViewModel.tasks.contains(where: {$0.saveHistory}) {
                                NoTasksView(taskViewToShow: false)
                                    .frame(maxHeight: .infinity)
                            } else {
                                ForEach (historyViewModel.tasks.filter{$0.saveHistory}, id: \.documentID){ task in
                                    HistoryTaskSection(
                                        viewModel: historyViewModel,
                                        task: task,
                                        title: "Location: \(task.locationName)",
                                        subtitle: "Date & Time: \(task.dateTime.formatted())"
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if historyViewModel.tasks.contains(where: {$0.saveHistory}) {
                        
                        HStack {
                            TextField("Enter email", text: $enteredEmail)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            
                                            if (enteredEmail.contains("@")) {
                                                historyViewModel.enteredEmailAddress(email: enteredEmail)
                                                enteredEmail = ""
                                            } else {
                                                print("enter valid email please")
                                            }
                                            
                                            
                                            
                                        }) {
                                            Image(systemName: !enteredEmail.isEmpty ? "paperplane.fill" : "paperplane")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                        .padding(.trailing, 15),
                                    alignment: .trailing
                                )
                        }
                        .padding()
                    }
                    
                }
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Sign Out", action: historyViewModel.signOut)
                            Button("Delete Account", action: {
                                historyViewModel.deleteAccount()
                            })
                        } label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .background(Color(red: 105/255, green: 155/255, blue: 157/255).ignoresSafeArea())
            }
            .onAppear {
                historyViewModel.fetchTasks()
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
            }
        }
        .animation(.easeInOut, value: showSomethingWentWrong)
        .onReceive(networkMonitor.$isConnected) { isConnected in
            print("Network status changed: \(isConnected)")
            showSomethingWentWrong = !isConnected
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

