//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//


import SwiftUI
import Combine

struct HistoryTaskItem: View {
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 30, height: 30)
                .overlay(Text("A").foregroundColor(.white).font(.headline))
            Text("List item")
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "checkmark.square.fill")
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color(red: 105/255, green: 155/255, blue: 157/255).opacity(0))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

struct HistoryTaskSection: View {
    var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.leading)
                .padding(.top, 10)
            
            
            ForEach(0..<4) { _ in
                HistoryTaskItem()
            }
        }
        .background(Color(red: 105/255, green: 155/255, blue: 157/255).opacity(1))
        .cornerRadius(10)
        .padding()
    }
}

struct HistoryView: View {
    @StateObject var historyViewModel = HistoryViewModel(loginViewModel: LoginViewModel())
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        if historyViewModel.tasks.isEmpty {
                        
                            NoTasksView(taskViewToShow: false)
                            
                        } else {
                            HistoryTaskSection(title: "Location One Task")
                            HistoryTaskSection(title: "Location Two Task")
                            HistoryTaskSection(title: "Location Three Task")
                        }
                    }
                    .padding(.top)
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

